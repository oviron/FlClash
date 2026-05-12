package main

import (
	"encoding/json"
	"fmt"
	"time"

	P "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/tunnel"
)

type updatableProvider interface {
	UpdatedAt() time.Time
}

type vehicleProvider interface {
	Vehicle() P.Vehicle
}

func queryExternalProviders() string {
	list := make([]ExternalProvider, 0)
	for _, p := range tunnel.Providers() {
		if p.VehicleType() == P.Compatible {
			continue
		}
		list = append(list, providerView(p, p.Count()))
	}
	for _, p := range tunnel.RuleProviders() {
		if p.VehicleType() == P.Compatible {
			continue
		}
		list = append(list, providerView(p, p.Count()))
	}
	data, _ := json.Marshal(list)
	return string(data)
}

func getExternalProvider(pType, name string) string {
	switch pType {
	case "Proxy":
		if p, ok := tunnel.Providers()[name]; ok && p.VehicleType() != P.Compatible {
			data, _ := json.Marshal(providerView(p, p.Count()))
			return string(data)
		}
	case "Rule":
		if p, ok := tunnel.RuleProviders()[name]; ok && p.VehicleType() != P.Compatible {
			data, _ := json.Marshal(providerView(p, p.Count()))
			return string(data)
		}
	}
	return ""
}

func updateExternalProvider(pType, name string) string {
	var p P.Provider
	switch pType {
	case "Proxy":
		if v, ok := tunnel.Providers()[name]; ok {
			p = v
		}
	case "Rule":
		if v, ok := tunnel.RuleProviders()[name]; ok {
			p = v
		}
	}
	if p == nil {
		return fmt.Sprintf("%s provider %q not found", pType, name)
	}
	if err := p.Update(); err != nil {
		return err.Error()
	}
	return ""
}

func providerView(p P.Provider, count int) ExternalProvider {
	view := ExternalProvider{
		Name:        p.Name(),
		Type:        p.Type().String(),
		VehicleType: p.VehicleType().String(),
		Count:       count,
	}
	if v, ok := p.(vehicleProvider); ok {
		view.Path = v.Vehicle().Path()
	}
	if u, ok := p.(updatableProvider); ok {
		view.UpdateAt = u.UpdatedAt()
	}
	return view
}
