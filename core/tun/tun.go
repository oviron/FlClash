//go:build android && cgo

package tun

import (
	"io"
	"net"
	"net/netip"
	"strings"

	"github.com/metacubex/mihomo/constant"
	LC "github.com/metacubex/mihomo/listener/config"
	"github.com/metacubex/mihomo/listener/sing_tun"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
)

// Fork-specific TUN device name. Will be parameterized when this code is
// extracted to libmihomo-android (Phase 3).
const deviceName = "FlClash"

// Hardcoded MTU matches CMfA. Android VpnService.Builder caps at 65535.
const tunMTU = 9000

// Start builds a sing_tun listener from the address/dns/stack inputs supplied
// by the Android VpnService.Builder side. Returns an io.Closer (the caller
// only needs Close) so libmihomo-android consumers do not have to import
// sing_tun directly.
func Start(fd int, stack string, address, dns string) (io.Closer, error) {
	var prefix4 []netip.Prefix
	var prefix6 []netip.Prefix
	tunStack, ok := constant.StackTypeMapping[strings.ToLower(stack)]
	if !ok {
		tunStack = constant.TunSystem
	}
	for _, a := range strings.Split(address, ",") {
		a = strings.TrimSpace(a)
		if len(a) == 0 {
			continue
		}
		prefix, err := netip.ParsePrefix(a)
		if err != nil {
			return nil, err
		}
		if prefix.Addr().Is4() {
			prefix4 = append(prefix4, prefix)
		} else {
			prefix6 = append(prefix6, prefix)
		}
	}

	var dnsHijack []string
	for _, d := range strings.Split(dns, ",") {
		d = strings.TrimSpace(d)
		if len(d) == 0 {
			continue
		}
		dnsHijack = append(dnsHijack, net.JoinHostPort(d, "53"))
	}

	options := LC.Tun{
		Enable:              true,
		Device:              deviceName,
		Stack:               tunStack,
		DNSHijack:           dnsHijack,
		AutoRoute:           false, // Route configured by Android VpnService.Builder, not mihomo.
		AutoDetectInterface: false,
		Inet4Address:        prefix4,
		Inet6Address:        prefix6,
		MTU:                 tunMTU,
		FileDescriptor:      fd,
	}

	listener, err := sing_tun.New(options, tunnel.Tunnel)
	if err != nil {
		return nil, err
	}
	log.Infoln("TUN started: addresses=%s stack=%s", address, tunStack)
	return listener, nil
}
