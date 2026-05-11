package main

import (
	"encoding/json"
	"unsafe"
)

type Action struct {
	Id     string      `json:"id"`
	Method Method      `json:"method"`
	Data   interface{} `json:"data"`
}

type ActionResult struct {
	Id       string      `json:"id"`
	Method   Method      `json:"method"`
	Data     interface{} `json:"data"`
	Code     int         `json:"code"`
	callback unsafe.Pointer
}

func (result ActionResult) Json() ([]byte, error) {
	data, err := json.Marshal(result)
	return data, err
}

func (result ActionResult) success(data interface{}) {
	result.Code = 0
	result.Data = data
	result.send()
}

func (result ActionResult) error(data interface{}) {
	result.Code = -1
	result.Data = data
	result.send()
}

func handleAction(action *Action, result ActionResult) {
	switch action.Method {
	case initClashMethod:
		paramsString, ok := action.Data.(string)
		if !ok {
			result.error("invalid data type")
			return
		}
		result.success(handleInitClash(paramsString))
		return
	case getIsInitMethod:
		result.success(handleGetIsInit())
		return
	case forceGcMethod:
		handleForceGC()
		result.success(true)
		return
	case shutdownMethod:
		result.success(handleShutdown())
		return
	case validateConfigMethod:
		path, ok := action.Data.(string)
		if !ok {
			result.error("invalid data type")
			return
		}
		result.success(handleValidateConfig(path))
		return
	case updateConfigMethod:
		s, ok := action.Data.(string)
		if !ok {
			result.error("invalid data type")
			return
		}
		data := []byte(s)
		result.success(handleUpdateConfig(data))
		return
	case setupConfigMethod:
		s, ok := action.Data.(string)
		if !ok {
			result.error("invalid data type")
			return
		}
		data := []byte(s)
		result.success(handleSetupConfig(data))
		return
	case getConfigMethod:
		path, ok := action.Data.(string)
		if !ok {
			result.error("invalid data type")
			return
		}
		config, err := handleGetConfig(path)
		if err != nil {
			result.error(err)
			return
		}
		result.success(config)
		return
	case resetTrafficMethod:
		handleResetTraffic()
		result.success(true)
		return
	case resetConnectionsMethod:
		result.success(handleResetConnections())
		return
	case sideLoadExternalProviderMethod:
		paramsString, ok := action.Data.(string)
		if !ok {
			result.error("invalid data type")
			return
		}
		var params = map[string]string{}
		if err := json.Unmarshal([]byte(paramsString), &params); err != nil {
			result.success(err.Error())
			return
		}
		handleSideLoadExternalProvider(
			params["providerName"],
			[]byte(params["data"]),
			func(value string) { result.success(value) },
		)
		return
	case updateGeoDataMethod:
		paramsString, ok := action.Data.(string)
		if !ok {
			result.error("invalid data type")
			return
		}
		var params = map[string]string{}
		err := json.Unmarshal([]byte(paramsString), &params)
		if err != nil {
			result.success(err.Error())
			return
		}
		geoType := params["geo-type"]
		handleUpdateGeoData(geoType, func(value string) {
			result.success(value)
		})
		return
	case startLogMethod:
		handleStartLog()
		result.success(true)
		return
	case stopLogMethod:
		handleStopLog()
		result.success(true)
		return
	case startListenerMethod:
		result.success(handleStartListener())
		return
	case stopListenerMethod:
		result.success(handleStopListener())
		return
	case getCountryCodeMethod:
		ip, ok := action.Data.(string)
		if !ok {
			result.error("invalid data type")
			return
		}
		handleGetCountryCode(ip, func(value string) {
			result.success(value)
		})
		return
	case crashMethod:
		result.success(true)
		handleCrash()
	case deleteFile:
		path, ok := action.Data.(string)
		if !ok {
			result.error("invalid data type")
			return
		}
		handleDelFile(path, result)
		return
	case getControllerEndpointMethod:
		result.success(GetControllerEndpoint())
		return
	default:
		nextHandle(action, result)
	}
}
