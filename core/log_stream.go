package main

import (
	"sync"

	"github.com/metacubex/mihomo/common/observable"
	"github.com/metacubex/mihomo/log"
)

// logSubscriber is guarded by logSubMu so concurrent start/stop cannot leak
// orphan subscriptions or spawn duplicate fan-out goroutines.
var (
	logSubscriber observable.Subscription[log.Event]
	logSubMu      sync.Mutex
)

func handleStartLog() {
	logSubMu.Lock()
	if logSubscriber != nil {
		log.UnSubscribe(logSubscriber)
		logSubscriber = nil
	}
	sub := log.Subscribe()
	logSubscriber = sub
	logSubMu.Unlock()

	if sub == nil {
		return
	}
	// Range over the local `sub` (not the package-level var) so that a future
	// start/stop reassigning logSubscriber does not race this goroutine.
	go func() {
		for logData := range sub {
			if logData.LogLevel < log.Level() {
				continue
			}
			sendMessage(Message{
				Type: LogMessage,
				Data: logData,
			})
		}
	}()
}

func handleStopLog() {
	logSubMu.Lock()
	defer logSubMu.Unlock()
	if logSubscriber != nil {
		log.UnSubscribe(logSubscriber)
		logSubscriber = nil
	}
}
