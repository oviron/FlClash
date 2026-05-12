package main

import (
	"net"

	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/component/mmdb"
	"github.com/metacubex/mihomo/component/updater"
	cp "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/tunnel"
)

func handleSideLoadExternalProvider(providerName string, data []byte, fn func(value string)) {
	go func() {
		runLock.Lock()
		defer runLock.Unlock()
		var found cp.Provider
		for n, p := range tunnel.Providers() {
			if n == providerName && p.VehicleType() != cp.Compatible {
				found = p
				break
			}
		}
		if found == nil {
			fn("external provider is not exist")
			return
		}
		psp, ok := found.(*provider.ProxySetProvider)
		if !ok {
			fn("not a proxy provider")
			return
		}
		if _, _, err := psp.SideUpdate(data); err != nil {
			fn(err.Error())
			return
		}
		fn("")
	}()
}

func handleUpdateGeoData(geoType string, fn func(value string)) {
	go func() {
		var err error
		switch geoType {
		case "MMDB":
			err = updater.UpdateMMDB()
		case "ASN":
			err = updater.UpdateASN()
		case "GEOIP":
			err = updater.UpdateGeoIp()
		case "GEOSITE":
			err = updater.UpdateGeoSite()
		}
		if err != nil {
			fn(err.Error())
			return
		}
		fn("")
	}()
}

func handleGetCountryCode(ip string, fn func(value string)) {
	go func() {
		runLock.Lock()
		defer runLock.Unlock()
		codes := mmdb.IPInstance().LookupCode(net.ParseIP(ip))
		if len(codes) == 0 {
			fn("")
			return
		}
		fn(codes[0])
	}()
}
