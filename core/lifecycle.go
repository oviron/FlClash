package main

import (
	"encoding/json"
	"runtime"
	"runtime/debug"

	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/hub/executor"
	"github.com/metacubex/mihomo/listener"
	"github.com/metacubex/mihomo/log"
)

var isInit = false

func handleInitClash(paramsString string) bool {
	runLock.Lock()
	defer runLock.Unlock()
	var params = InitParams{}
	if err := json.Unmarshal([]byte(paramsString), &params); err != nil {
		return false
	}
	version = params.Version
	constant.SetHomeDir(params.HomeDir)
	isInit = true
	return isInit
}

func handleGetIsInit() bool {
	return isInit
}

func handleForceGC() {
	log.Infoln("[APP] request force GC")
	runtime.GC()
	debug.FreeOSMemory()
}

func handleShutdown() bool {
	handleUnsubscribeConnections()
	handleStopLog()
	listener.Cleanup()
	executor.Shutdown()
	handleForceGC()
	isInit = false
	return true
}

func handleCrash() {
	panic("handle invoke crash")
}
