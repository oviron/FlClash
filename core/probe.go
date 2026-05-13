package main

import (
	"context"
	"io"
	"time"

	mihomoHttp "github.com/metacubex/mihomo/component/http"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"

	"github.com/metacubex/http"
)

// rejectedProbeBody is a sentinel JSON the Dart layer recognises and renders
// as a "default route REJECTed" badge instead of an IP. Mihomo's catch-all
// MATCH,REJECT in whitelist-mode profiles means there IS no default-route
// exit-IP — we shouldn't lie and show one.
const rejectedProbeBody = `{"status":"REJECT"}`

// handleProbeCurrentProxyIp resolves the "what IP would mihomo show for a
// piece of traffic that didn't match any specific rule" question. The answer
// depends entirely on mihomo's current mode:
//
//   - Direct mode: mihomo bypasses rules → traffic goes DIRECT → home IP.
//   - Global  mode: mihomo bypasses rules → traffic goes through whatever
//     proxy the user selected in the builtin GLOBAL group.
//   - Rule    mode: mihomo walks the rule chain; the FINAL top-level
//     MATCH rule (catch-all) determines the default exit. Sub-rules' MATCH
//     are scoped to their sub-rule and don't define the global default.
//
// We probe through whichever proxy adapter that resolves to via
// WithSpecialProxy, which bypasses the rule chain entirely on dispatch
// (resolveMetadata early-returns when SpecialProxy != ""). For REJECT we
// return a sentinel so the dashboard renders "REJECT" instead of a fake IP
// or an infinite spinner.
func handleProbeCurrentProxyIp() string {
	target := determineProbeTarget()
	if target == "REJECT" {
		return rejectedProbeBody
	}

	ctx, cancel := context.WithTimeout(context.Background(), 8*time.Second)
	defer cancel()
	resp, err := mihomoHttp.HttpRequest(
		ctx,
		"https://ipinfo.io/json",
		http.MethodGet,
		nil,
		nil,
		mihomoHttp.WithSpecialProxy(target),
	)
	if err != nil {
		return ""
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return ""
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return ""
	}
	return string(body)
}

func determineProbeTarget() string {
	switch tunnel.Mode() {
	case tunnel.Direct:
		return "DIRECT"
	case tunnel.Global:
		return "GLOBAL"
	default:
		// Rule mode. Find the first top-level MATCH rule — it's a catch-all,
		// so first match-by-iteration = whatever fires for unspecified traffic.
		for _, rule := range tunnel.Rules() {
			if rule.RuleType() == C.MATCH {
				return rule.Adapter()
			}
		}
		// No MATCH rule means mihomo has no catch-all; fall back to GLOBAL
		// (which always exists as a builtin selector).
		return "GLOBAL"
	}
}
