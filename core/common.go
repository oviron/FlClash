package main

import (
	b "bytes"
	"encoding/json"
	"os"
	"path/filepath"
	"runtime"
	"sync"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/inbound"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/config"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/hub/executor"
	"github.com/metacubex/mihomo/listener"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
)

var (
	currentConfig     *config.Config
	version           = 0
	isRunning         = false
	runLock           sync.Mutex
	proxyGroupOrder   []string
	proxyGroupOrderMu sync.RWMutex
)

func updateListeners() {
	if !isRunning {
		return
	}
	if currentConfig == nil {
		return
	}
	listeners := currentConfig.Listeners
	general := currentConfig.General
	listener.PatchInboundListeners(listeners, tunnel.Tunnel, true)

	allowLan := general.AllowLan
	listener.SetAllowLan(allowLan)
	inbound.SetSkipAuthPrefixes(general.SkipAuthPrefixes)
	inbound.SetAllowedIPs(general.LanAllowedIPs)
	inbound.SetDisAllowedIPs(general.LanDisAllowedIPs)

	bindAddress := general.BindAddress
	listener.SetBindAddress(bindAddress)
	listener.ReCreateHTTP(general.Port, tunnel.Tunnel)
	listener.ReCreateSocks(general.SocksPort, tunnel.Tunnel)
	listener.ReCreateRedir(general.RedirPort, tunnel.Tunnel)
	listener.ReCreateTProxy(general.TProxyPort, tunnel.Tunnel)
	listener.ReCreateMixed(general.MixedPort, tunnel.Tunnel)
	listener.ReCreateShadowSocks(general.ShadowSocksConfig, tunnel.Tunnel)
	listener.ReCreateVmess(general.VmessConfig, tunnel.Tunnel)
	listener.ReCreateTuic(general.TuicServer, tunnel.Tunnel)
}

func patchSelectGroup(mapping map[string]string) {
	allProxies := make(map[string]C.Proxy)
	for name, proxy := range tunnel.Proxies() {
		allProxies[name] = proxy
	}
	for _, p := range tunnel.Providers() {
		for _, proxy := range p.Proxies() {
			allProxies[proxy.Name()] = proxy
		}
	}
	for name, proxy := range allProxies {
		outbound, ok := proxy.(*adapter.Proxy)
		if !ok {
			continue
		}

		selector, ok := outbound.ProxyAdapter.(outboundgroup.SelectAble)
		if !ok {
			continue
		}

		selected, exist := mapping[name]
		if !exist {
			continue
		}

		selector.ForceSet(selected)
	}
}

func defaultSetupParams() *SetupParams {
	return &SetupParams{
		SelectedMap: map[string]string{},
	}
}

func readFile(path string) ([]byte, error) {
	if _, err := os.Stat(path); os.IsNotExist(err) {
		return nil, err
	}
	data, err := os.ReadFile(path) // #nosec G304 -- path supplied by FlClash UI, runs in app sandbox
	if err != nil {
		return nil, err
	}

	return data, err
}

func updateConfig(params *UpdateParams) {
	runLock.Lock()
	defer runLock.Unlock()
	general := currentConfig.General
	if params.MixedPort != nil {
		general.MixedPort = *params.MixedPort
	}
	if params.Sniffing != nil {
		general.Sniffing = *params.Sniffing
		tunnel.SetSniffing(general.Sniffing)
	}
	if params.FindProcessMode != nil {
		general.FindProcessMode = *params.FindProcessMode
		tunnel.SetFindProcessMode(general.FindProcessMode)
	}
	if params.TCPConcurrent != nil {
		general.TCPConcurrent = *params.TCPConcurrent
		dialer.SetTcpConcurrent(general.TCPConcurrent)
	}
	if params.Interface != nil {
		general.Interface = *params.Interface
		dialer.DefaultInterface.Store(general.Interface)
	}
	if params.UnifiedDelay != nil {
		general.UnifiedDelay = *params.UnifiedDelay
		adapter.UnifiedDelay.Store(general.UnifiedDelay)
	}
	if params.Mode != nil {
		general.Mode = *params.Mode
		tunnel.SetMode(general.Mode)
	}
	if params.LogLevel != nil {
		general.LogLevel = *params.LogLevel
		log.SetLevel(general.LogLevel)
	}
	if params.IPv6 != nil {
		general.IPv6 = *params.IPv6
		resolver.DisableIPv6 = !general.IPv6
	}
	if params.Tun != nil {
		general.Tun.Enable = params.Tun.Enable
		general.Tun.AutoRoute = *params.Tun.AutoRoute
		general.Tun.Device = *params.Tun.Device
		general.Tun.RouteAddress = *params.Tun.RouteAddress
		general.Tun.DNSHijack = *params.Tun.DNSHijack
		general.Tun.Stack = *params.Tun.Stack
	}

	updateListeners()
}

func applyConfig(params *SetupParams) error {
	runtime.GC()
	runLock.Lock()
	defer runLock.Unlock()
	configPath := filepath.Join(C.Path.HomeDir(), "config.yaml")
	var err error
	currentConfig, err = executor.ParseWithPath(configPath)
	if err != nil {
		currentConfig, _ = config.ParseRawConfig(config.DefaultRawConfig())
	}
	captureProxyGroupOrder(configPath)
	executor.ApplyConfig(currentConfig, true)
	patchSelectGroup(params.SelectedMap)
	updateListeners()
	return err
}

func captureProxyGroupOrder(path string) {
	order := []string{}
	defer func() {
		proxyGroupOrderMu.Lock()
		proxyGroupOrder = order
		proxyGroupOrderMu.Unlock()
	}()
	buf, rerr := readFile(path)
	if rerr != nil {
		return
	}
	raw, perr := config.UnmarshalRawConfig(buf)
	if perr != nil || raw == nil {
		return
	}
	for _, g := range raw.ProxyGroup {
		if name, ok := g["name"].(string); ok && name != "" {
			order = append(order, name)
		}
	}
}

func queryProxyGroupOrder() string {
	proxyGroupOrderMu.RLock()
	defer proxyGroupOrderMu.RUnlock()
	data, _ := json.Marshal(proxyGroupOrder)
	return string(data)
}

func UnmarshalJson(data []byte, v any) error {
	decoder := json.NewDecoder(b.NewReader(data))
	decoder.UseNumber()
	err := decoder.Decode(v)
	return err
}
