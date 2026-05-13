package main

import (
	"context"
	"io"
	"time"

	mihomoHttp "github.com/metacubex/mihomo/component/http"
	"github.com/metacubex/http"
)

// handleProbeCurrentProxyIp does an HTTP GET to ipinfo.io/json **through the
// current GLOBAL proxy adapter** and returns the response body as-is for the
// Dart side to parse.
//
// Why this exists: the Dashboard "Detect" widget on phone needs to show the
// exit-IP of whichever proxy the user has currently selected. The naive Dart
// approach (lib/common/request.dart) sends the request via _clashDio →
// localhost:7890 (mihomo's mixed inbound), and in a whitelist-mode profile
// the catch-all `MATCH,REJECT` swallows it before the user's VPN group has a
// chance to handle it. On CMFA-build Android we can't reliably set a
// PROCESS-NAME rule because mihomo's loopback path lacks process resolution
// (DefaultPackageNameResolver is registered only for TUN packets).
//
// `WithSpecialProxy("GLOBAL")` makes mihomo set metadata.SpecialProxy and
// take the early-return branch in resolveMetadata (tunnel/tunnel.go:310),
// completely bypassing user rules and dispatching directly via the GLOBAL
// selector group's current member. Same mechanism that proxy-providers and
// rule-providers use via their `proxy:` YAML field.
func handleProbeCurrentProxyIp() string {
	ctx, cancel := context.WithTimeout(context.Background(), 8*time.Second)
	defer cancel()

	resp, err := mihomoHttp.HttpRequest(
		ctx,
		"https://ipinfo.io/json",
		http.MethodGet,
		nil,
		nil,
		mihomoHttp.WithSpecialProxy("GLOBAL"),
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
