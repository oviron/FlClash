package main

import (
	"github.com/metacubex/mihomo/common/observable"
	"github.com/metacubex/mihomo/log"
)

var logSubscriber observable.Subscription[log.Event]

func handleStartLog() {
	if logSubscriber != nil {
		log.UnSubscribe(logSubscriber)
		logSubscriber = nil
	}
	logSubscriber = log.Subscribe()
	if logSubscriber == nil {
		return
	}
	go func() {
		for logData := range logSubscriber {
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
	if logSubscriber != nil {
		log.UnSubscribe(logSubscriber)
		logSubscriber = nil
	}
}
