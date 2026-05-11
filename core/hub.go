package main

import (
	"encoding/json"
	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/common/observable"
	"github.com/metacubex/mihomo/component/mmdb"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/component/updater"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/constant/features"
	cp "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/hub/executor"
	"github.com/metacubex/mihomo/listener"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
	"net"
	"os"
	"runtime"
	"runtime/debug"
)

var (
	isInit        = false
	logSubscriber observable.Subscription[log.Event]
)

func handleInitClash(paramsString string) bool {
	runLock.Lock()
	defer runLock.Unlock()
	var params = InitParams{}
	err := json.Unmarshal([]byte(paramsString), &params)
	if err != nil {
		return false
	}
	version = params.Version
	constant.SetHomeDir(params.HomeDir)
	isInit = true
	return isInit
}

func handleStartListener() bool {
	runLock.Lock()
	defer runLock.Unlock()
	isRunning = true
	updateListeners()
	resolver.ResetConnection()
	return true
}

func handleStopListener() bool {
	runLock.Lock()
	defer runLock.Unlock()
	isRunning = false
	listener.Cleanup()
	resolver.ResetConnection()
	return true
}

func handleGetIsInit() bool {
	return isInit
}

func handleForceGC() {
	log.Infoln("[APP] request force GC")
	runtime.GC()
	if features.CMFA {
		debug.FreeOSMemory()
	}
}

func handleShutdown() bool {
	stopListeners()
	executor.Shutdown()
	handleForceGC()
	isInit = false
	return true
}

func handleValidateConfig(path string) string {
	buf, err := readFile(path)
	_, err = config.UnmarshalRawConfig(buf)
	if err != nil {
		return err.Error()
	}
	return ""
}

func handleGetTraffic(_ bool) string {
	up, down := statistic.DefaultManager.Now()
	data, err := json.Marshal(map[string]int64{"up": up, "down": down})
	if err != nil {
		log.Errorln("Error: %s", err)
		return ""
	}
	return string(data)
}

func handleGetTotalTraffic(_ bool) string {
	up, down := statistic.DefaultManager.Total()
	data, err := json.Marshal(map[string]int64{"up": up, "down": down})
	if err != nil {
		log.Errorln("Error: %s", err)
		return ""
	}
	return string(data)
}

func handleResetTraffic() {
	statistic.DefaultManager.ResetStatistic()
}

func handleResetConnections() bool {
	runLock.Lock()
	defer runLock.Unlock()
	resolver.ResetConnection()
	return true
}

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

func handleSuspend(suspended bool) bool {
	if suspended {
		tunnel.OnSuspend()
	} else {
		tunnel.OnRunning()
	}
	return true
}

func handleStartLog() {
	if logSubscriber != nil {
		log.UnSubscribe(logSubscriber)
		logSubscriber = nil
	}
	logSubscriber = log.Subscribe()
	go func() {
		for logData := range logSubscriber {
			if logData.LogLevel < log.Level() {
				continue
			}
			message := &Message{
				Type: LogMessage,
				Data: logData,
			}
			sendMessage(*message)
		}
	}()
}

func handleStopLog() {
	if logSubscriber != nil {
		log.UnSubscribe(logSubscriber)
		logSubscriber = nil
	}
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

func handleGetConfig(path string) (*config.RawConfig, error) {
	bytes, err := readFile(path)
	if err != nil {
		return nil, err
	}
	prof, err := config.UnmarshalRawConfig(bytes)
	if err != nil {
		return nil, err
	}
	return prof, nil
}

func handleCrash() {
	panic("handle invoke crash")
}

func handleUpdateConfig(bytes []byte) string {
	var params = &UpdateParams{}
	err := json.Unmarshal(bytes, params)
	if err != nil {
		return err.Error()
	}
	updateConfig(params)
	return ""
}

func handleDelFile(path string, result ActionResult) {
	go func() {
		fileInfo, err := os.Stat(path)
		if err != nil {
			if !os.IsNotExist(err) {
				result.success(err.Error())
			}
			result.success("")
			return
		}
		if fileInfo.IsDir() {
			err = os.RemoveAll(path)
			if err != nil {
				result.success(err.Error())
				return
			}
		} else {
			err = os.Remove(path)
			if err != nil {
				result.success(err.Error())
				return
			}
		}
		result.success("")
	}()
}

func handleSetupConfig(bytes []byte) string {
	if !isInit {
		return "not initialized"
	}
	var params = defaultSetupParams()
	err := UnmarshalJson(bytes, params)
	if err != nil {
		log.Errorln("unmarshalRawConfig error %v", err)
		_ = applyConfig(defaultSetupParams())
		return err.Error()
	}
	err = applyConfig(params)
	if err != nil {
		return err.Error()
	}
	if cErr := StartController(); cErr != nil {
		log.Errorln("[Controller] start failed: %v", cErr)
	}
	return ""
}
