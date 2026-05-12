package main

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/common/utils"
	"github.com/metacubex/mihomo/component/profile/cachefile"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

// handleGetProxies returns a JSON snapshot of all proxies (from tunnel) and
// proxies exposed by providers, merged into a single `{name: proxy}` map and
// wrapped under `{"proxies": {...}}` to match the existing mihomo REST shape
// the Dart layer already parses.
func handleGetProxies() string {
	all := make(map[string]C.Proxy)
	for name, proxy := range tunnel.Proxies() {
		all[name] = proxy
	}
	for _, p := range tunnel.Providers() {
		for _, proxy := range p.Proxies() {
			all[proxy.Name()] = proxy
		}
	}
	data, err := json.Marshal(map[string]any{"proxies": all})
	if err != nil {
		return ""
	}
	return string(data)
}

// handleChangeProxy switches the SelectAble adapter `group` to `name`. Returns
// an error if the group is not found or is not a selector-style group.
func handleChangeProxy(group, name string) error {
	proxy, ok := tunnel.Proxies()[group]
	if !ok {
		return fmt.Errorf("group %q not found", group)
	}
	selector, ok := proxy.Adapter().(outboundgroup.SelectAble)
	if !ok {
		return fmt.Errorf("group %q is not selectable", group)
	}
	if err := selector.Set(name); err != nil {
		return err
	}
	cachefile.Cache().SetSelected(proxy.Name(), name)
	return nil
}

// handleAsyncTestDelay runs a URL-test against `name` with the given URL and
// timeout (ms). Returns the round-trip in ms, or -1 on timeout/failure.
func handleAsyncTestDelay(name, url string, timeoutMs int) int {
	proxy, ok := proxyByName(name)
	if !ok {
		return -1
	}
	if timeoutMs <= 0 {
		timeoutMs = 5000
	}
	ctx, cancel := context.WithTimeout(context.Background(), time.Duration(timeoutMs)*time.Millisecond)
	defer cancel()
	delay, err := proxy.URLTest(ctx, url, utils.IntRanges[uint16](nil))
	if err != nil || ctx.Err() != nil || delay == 0 {
		return -1
	}
	return int(delay)
}

func proxyByName(name string) (C.Proxy, bool) {
	if p, ok := tunnel.Proxies()[name]; ok {
		return p, true
	}
	for _, prov := range tunnel.Providers() {
		for _, p := range prov.Proxies() {
			if p.Name() == name {
				return p, true
			}
		}
	}
	return nil, false
}
