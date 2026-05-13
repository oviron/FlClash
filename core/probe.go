package main

import (
	"context"
	"io"
	"net/http"
	"strings"
	"time"

	mihomoHttp "github.com/metacubex/mihomo/component/http"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

// rejectedProbeBody — sentinel JSON для Dart, чтобы UI нарисовала REJECT-badge
// вместо вечного спиннера, когда default-route у пользователя — REJECT.
const rejectedProbeBody = `{"status":"REJECT"}`

// handleProbeCurrentProxyIp возвращает JSON ipinfo.io для default-route exit-IP.
// Target выбирается по mode'у Dart UI (modeHint) и затем минует rules через
// WithSpecialProxy (resolveMetadata делает early-return при SpecialProxy != "").
// Пустой modeHint → fallback на tunnel.Mode() (может lag'нуть на смену mode).
func handleProbeCurrentProxyIp(modeHint string) string {
	target := determineProbeTarget(modeHint)
	if target == "REJECT" {
		return rejectedProbeBody
	}

	ctx, cancel := context.WithTimeout(context.Background(), 8*time.Second)
	defer cancel()
	resp, err := mihomoHttp.HttpRequest(
		ctx, "https://ipinfo.io/json", http.MethodGet, nil, nil,
		mihomoHttp.WithSpecialProxy(target),
	)
	if err != nil || resp.StatusCode != http.StatusOK {
		if resp != nil {
			resp.Body.Close()
		}
		return ""
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return ""
	}
	return string(body)
}

func determineProbeTarget(modeHint string) string {
	switch resolveMode(modeHint) {
	case tunnel.Direct:
		return "DIRECT"
	case tunnel.Global:
		return "GLOBAL"
	}
	// Rule mode: первое top-level MATCH правило = default route для трафика
	// который не попал ни под одно более узкое правило. Sub-rules' MATCH
	// scoped к sub-rule, не считаются.
	for _, rule := range tunnel.Rules() {
		if rule.RuleType() == C.MATCH {
			return rule.Adapter()
		}
	}
	// MATCH вообще отсутствует — mihomo дропает unspecified traffic. Показать
	// REJECT honestly вместо лживого GLOBAL[selected].
	return "REJECT"
}

func resolveMode(modeHint string) tunnel.TunnelMode {
	if m, ok := tunnel.ModeMapping[strings.ToLower(modeHint)]; ok {
		return m
	}
	return tunnel.Mode()
}
