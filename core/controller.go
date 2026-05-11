package main

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"io"
	"net"
	"net/http"
	"sync"
	"time"

	"github.com/metacubex/mihomo/hub/route"
	"github.com/metacubex/mihomo/log"
)

const (
	controllerPortStart     = 19999
	controllerPortEnd       = 20009
	controllerVerifyDelay   = 50 * time.Millisecond
	controllerVerifyTimeout = 2 * time.Second
)

var (
	controllerMu      sync.Mutex
	controllerPort    int
	controllerSecret  string
	controllerStarted bool
)

func generateControllerSecret() (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return hex.EncodeToString(b), nil
}

func verifyControllerPort(port int, secret string) bool {
	url := fmt.Sprintf("http://127.0.0.1:%d/version", port)
	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		return false
	}
	req.Header.Set("Authorization", "Bearer "+secret)
	client := &http.Client{Timeout: controllerVerifyTimeout}
	resp, err := client.Do(req)
	if err != nil {
		return false
	}
	defer func() { _ = resp.Body.Close() }()
	_, _ = io.Copy(io.Discard, resp.Body)
	return resp.StatusCode == http.StatusOK
}

func StartController() error {
	controllerMu.Lock()
	defer controllerMu.Unlock()
	if controllerStarted {
		return nil
	}

	if controllerSecret == "" {
		secret, err := generateControllerSecret()
		if err != nil {
			return fmt.Errorf("generate controller secret: %w", err)
		}
		controllerSecret = secret
	}

	route.SetEmbedMode(true)

	for port := controllerPortStart; port <= controllerPortEnd; port++ {
		addr := fmt.Sprintf("127.0.0.1:%d", port)

		l, err := net.Listen("tcp", addr)
		if err != nil {
			log.Warnln("[Controller] port %d busy: %v", port, err)
			continue
		}
		_ = l.Close()

		route.ReCreateServer(&route.Config{
			Addr:   addr,
			Secret: controllerSecret,
		})

		time.Sleep(controllerVerifyDelay)

		if verifyControllerPort(port, controllerSecret) {
			controllerPort = port
			controllerStarted = true
			log.Infoln("[Controller] started at 127.0.0.1:%d", port)
			return nil
		}

		log.Warnln("[Controller] port %d bound but /version verify failed", port)
	}

	return fmt.Errorf("controller: no free port in range %d-%d", controllerPortStart, controllerPortEnd)
}

func GetControllerEndpoint() string {
	controllerMu.Lock()
	defer controllerMu.Unlock()
	if !controllerStarted || controllerPort == 0 {
		return ""
	}
	return fmt.Sprintf("http://127.0.0.1:%d?token=%s", controllerPort, controllerSecret)
}
