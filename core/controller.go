package main

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"net"
	"sync"
)

const (
	controllerPortStart = 19999
	controllerPortEnd   = 20009
)

var (
	controllerMu     sync.Mutex
	controllerPort   int
	controllerSecret string
)

// InitController picks a free 127.0.0.1 port from the range and generates the
// bearer secret once per process. The actual HTTP listener is brought up by
// mihomo inside hub.ApplyConfig via cfg.Controller.ExternalController.
func InitController() error {
	controllerMu.Lock()
	defer controllerMu.Unlock()
	if controllerPort != 0 {
		return nil
	}
	if controllerSecret == "" {
		b := make([]byte, 32)
		if _, err := rand.Read(b); err != nil {
			return err
		}
		controllerSecret = hex.EncodeToString(b)
	}
	for port := controllerPortStart; port <= controllerPortEnd; port++ {
		l, err := net.Listen("tcp", fmt.Sprintf("127.0.0.1:%d", port))
		if err != nil {
			continue
		}
		_ = l.Close()
		controllerPort = port
		return nil
	}
	return fmt.Errorf("controller: no free port in %d-%d", controllerPortStart, controllerPortEnd)
}

func ControllerAddr() string {
	controllerMu.Lock()
	defer controllerMu.Unlock()
	if controllerPort == 0 {
		return ""
	}
	return fmt.Sprintf("127.0.0.1:%d", controllerPort)
}

func ControllerSecret() string {
	controllerMu.Lock()
	defer controllerMu.Unlock()
	return controllerSecret
}

func GetControllerEndpoint() string {
	controllerMu.Lock()
	defer controllerMu.Unlock()
	if controllerPort == 0 || controllerSecret == "" {
		return ""
	}
	return fmt.Sprintf("http://127.0.0.1:%d?token=%s", controllerPort, controllerSecret)
}
