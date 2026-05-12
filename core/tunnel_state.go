package main

import (
	"encoding/json"

	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/listener"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

func handleStartListener() bool {
	runLock.Lock()
	defer runLock.Unlock()
	isRunning = true
	updateListeners()
	resolver.ResetConnection()
	return true
}

func handleStopListener() bool {
	runLock.Lock()
	defer runLock.Unlock()
	isRunning = false
	listener.Cleanup()
	resolver.ResetConnection()
	return true
}

func handleSuspend(suspended bool) bool {
	if suspended {
		tunnel.OnSuspend()
	} else {
		tunnel.OnRunning()
	}
	return true
}

func handleResetTraffic() {
	statistic.DefaultManager.ResetStatistic()
}

func handleResetConnections() bool {
	runLock.Lock()
	defer runLock.Unlock()
	resolver.ResetConnection()
	return true
}

func handleGetTraffic() string {
	up, down := statistic.DefaultManager.Now()
	data, _ := json.Marshal(map[string]int64{"up": up, "down": down})
	return string(data)
}
