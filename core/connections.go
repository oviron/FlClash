package main

import (
	"context"
	"encoding/json"
	"sync"
	"time"

	"github.com/metacubex/mihomo/tunnel/statistic"
)

const connectionsTickInterval = time.Second

var (
	connectionsMu     sync.Mutex
	connectionsCancel context.CancelFunc
)

func handleGetConnections() string {
	data, _ := json.Marshal(statistic.DefaultManager.Snapshot())
	return string(data)
}

func handleSubscribeConnections() {
	connectionsMu.Lock()
	defer connectionsMu.Unlock()
	if connectionsCancel != nil {
		connectionsCancel()
	}
	ctx, cancel := context.WithCancel(context.Background())
	connectionsCancel = cancel
	go func() {
		ticker := time.NewTicker(connectionsTickInterval)
		defer ticker.Stop()
		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
				data, _ := json.Marshal(statistic.DefaultManager.Snapshot())
				sendMessage(Message{
					Type: ConnectionsMessage,
					Data: json.RawMessage(data),
				})
			}
		}
	}()
}

func handleUnsubscribeConnections() {
	connectionsMu.Lock()
	defer connectionsMu.Unlock()
	if connectionsCancel != nil {
		connectionsCancel()
		connectionsCancel = nil
	}
}

func handleCloseConnection(id string) bool {
	tracker := statistic.DefaultManager.Get(id)
	if tracker == nil {
		return false
	}
	_ = tracker.Close()
	return true
}

func handleCloseAllConnections() bool {
	statistic.DefaultManager.Range(func(t statistic.Tracker) bool {
		_ = t.Close()
		return true
	})
	return true
}
