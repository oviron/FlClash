package main

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"net"

	"github.com/metacubex/mihomo/hub/route"
)

const (
	controllerPortStart = 19999
	controllerPortEnd   = 20009
)

var (
	controllerPort   int
	controllerSecret string
)

func InitController() error {
	if controllerPort != 0 {
		return nil
	}
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return err
	}
	controllerSecret = hex.EncodeToString(b)
	for port := controllerPortStart; port <= controllerPortEnd; port++ {
		l, err := net.Listen("tcp", fmt.Sprintf("127.0.0.1:%d", port))
		if err != nil {
			continue
		}
		_ = l.Close()
		controllerPort = port
		route.SetEmbedMode(true)
		route.ReCreateServer(&route.Config{
			Addr:   fmt.Sprintf("127.0.0.1:%d", port),
			Secret: controllerSecret,
		})
		return nil
	}
	return fmt.Errorf("controller: no free port in %d-%d", controllerPortStart, controllerPortEnd)
}

func GetControllerEndpoint() string {
	if controllerPort == 0 || controllerSecret == "" {
		return ""
	}
	return fmt.Sprintf("http://127.0.0.1:%d?token=%s", controllerPort, controllerSecret)
}
