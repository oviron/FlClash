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

func handleInitClash(paramsString string) bool {
	runLock.Lock()
	defer runLock.Unlock()
	var params = InitParams{}
	if err := json.Unmarshal([]byte(paramsString), &params); err != nil {
		return false
	}
	version.Store(int32(params.Version))
	constant.SetHomeDir(params.HomeDir)
	isInit.Store(true)
	return true
}

func handleGetIsInit() bool {
	return isInit.Load()
}

func handleForceGC() {
	log.Infoln("[APP] request force GC")
	runtime.GC()
	debug.FreeOSMemory()
}

// Subscription cleanup runs outside runLock (each has its own mutex); the
// executor/listener/eventListener teardown runs under runLock to be exclusive
// with applyConfig/updateConfig.
func handleShutdown() bool {
	handleUnsubscribeConnections()
	handleStopLog()

	runLock.Lock()
	listener.Cleanup()
	executor.Shutdown()
	handleForceGC()
	isInit.Store(false)
	runLock.Unlock()

	// Symmetric with setEventListener: release the final JNI global ref so
	// it does not leak past process lifetime.
	eventListenerMu.Lock()
	if eventListener != nil {
		releaseObject(eventListener)
		eventListener = nil
	}
	eventListenerMu.Unlock()
	return true
}
