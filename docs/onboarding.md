# Onboarding and Zero-to-Profile: Paste-and-Go Design

Status: v1 implemented and verified on-device (emulator + pinned core). The connect-time 204 honesty gate (section 11) is now wired into the app: a pasted key auto-connects and `QuickStartVerifyOverlay`/`decideVerifyStatus` probe the tunnel, showing verifying -> verified / honest-fail. Only a 204 **success** through a live operator server remains to be exercised end-to-end.
Target line: 0.16 / 0.17
Last updated: 2026-06-29 (Part II rewritten — user-extensible constructor, no-magic-values principle, catalog library, recognize-don't-rebuild bridge)
Audience of the app: users on censored networks (RU / IR / CN), Android-first, no telemetry.

This file now covers two adjacent features. Part I (sections 1-21) is the paste-and-go
onboarding path: artifact in, verified full-tunnel connection out, zero vocabulary. Part II
(at the end) is the next screen the same user opens: a user-extensible, plain-language routing
constructor over the profile. The user connects their own lists, composes their own routing
scenarios from those lists, and assigns them to apps, building from scratch — and every value
they set is a CHOICE from an enumerable set, never a mihomo identifier they must know.

This document is the single source for the onboarding redesign: the user pain, the
findings that ground it, the design principles, the product flow, the generated-profile
spec, and the staged implementation plan. It was produced from two adversarially-verified
multi-agent research passes (code + UX + competitors + protocol, then user-pain +
zero-to-profile product design); a provenance note is at the end.

## Implementation status (2026-06-28)

The v1 paste-and-go path is implemented and gated green by the fork's full CI set
(dart format, flutter analyze --fatal-infos, DCM check-unused-code/files, the full
test suite). What shipped:

- `lib/common/share_link.dart` - Dart parsers for vless (reality/ws/grpc/tls), vmess,
  ss (SIP002), trojan, plus a base64-subscription decoder.
- `lib/services/quickstart_config_service.dart` - artifact classifier and a synthesizer
  that wraps parsed nodes into a complete config (inline `proxies:` + a single url-test
  `PROXY` group + `MATCH,PROXY`, no `dns:` so the hardened model defaults apply).
- Ingestion wired through one `addProfileFromText` funnel; the three http-only gates
  (`isUrl`, gallery-QR, `BarcodeType.url`) relaxed; `Profile.update()` converts a
  base64/share-link subscription body; a "Paste your key" CTA on the empty first-run
  screen reads the clipboard or opens a format-agnostic paste dialog.

Mechanism note (decided after reading the live code, supersedes the `type: file`
sidecar idea in section 15): the converter is a **Dart-side parser that inlines
`proxies:`**, not a core `type: file` proxy-provider. Reason: a provider-only config
makes the static Dart gates read zero nodes and leaves Reality unreadable from Dart,
whereas inlining keeps the node-count gate working, lets us write `reality-opts`
ourselves (certainty), keeps `validateConfig` self-contained, and is fully unit-testable.

P1 (the load-bearing risk in section 18) is **resolved**. Two independent proofs:

- `mihomo -t` on the exact pinned engine (Meta v1.19.26) accepts the synthesized config
  for vless+reality (`public-key`/`short-id`/`client-fingerprint`/`flow`), vmess+ws+tls,
  ss, trojan, the url-test group, and `MATCH,PROXY`.
- End-to-end on an Android 15 / arm64 emulator running the **release APK** with the pinned
  native core (libclash, mihomo v1.19.26): pasting a vless+reality link through the
  Paste-your-key dialog creates a profile (`1 group / 1 node`), the native `validateConfig`
  accepts the synthesized config, the core loads the node, and the url-test group
  health-checks it via `cp.cloudflare.com/generate_204`. A dead test endpoint correctly
  reports `alive: false` (the honest-fail path, never a false "connected").

The only unexercised assertion is a 204 **success** through a live operator VLESS server
(the test used a fake endpoint, so `alive: false` is the correct result). That is purely
server-dependent, not a code-level unknown.

## Table of contents

1. The one-sentence product
2. Problem and root cause
3. Key technical finding: the core already parses share links
4. Pain thesis
5. Personas
6. The premise, reframed (artifact vs behavior)
7. Friction map
8. Design principles
9. The golden path, screen by screen
10. Generated-profile spec (the region-safe envelope)
11. Honesty gate, failure and trust UX
12. Progressive disclosure
13. Segmented flows
14. Competitor landscape
15. Implementation
16. Roadmap
17. Scope: v1 vs named backlog
18. Risks
19. Measurement plan
20. Changelog: critique to fix
21. Provenance

---

## 1. The one-sentence product

When a censored-network user receives one thing (a `vless://` line, a QR, a base64 blob,
or a subscription URL) and cannot tell which, they paste it into a single box and, with
zero further input and zero new vocabulary, the app builds a complete, leak-hardened
tunnel underneath them and proves it works with a real request, not a green dot. The
deep-config power that differentiates this fork stays one tap away, never in the way.

---

## 2. Problem and root cause

Today a user cannot install FlClash, paste a vless link or a subscription, and connect.
There are two independent causes that compound.

### Technical

The Dart layer has zero share-link or base64 ingestion (a grep for
`vless`/`vmess`/`ss`/`trojan`/`hysteria2`/`tuic` across `lib/`, minus generated and l10n,
returns 0 hits). A bare link is rejected at three layers:

1. `isUrl` (`lib/common/string.dart:8`) requires `^(http|https|ftp)://`, so a `vless://`
   string is refused by the import field.
2. The dio GET in `Profile.update()` (`request.dart:61`) cannot fetch a non-http scheme,
   so anything that is not an http(s) URL has no path forward.
3. Native `validateConfig` (`lib/models/profile.dart:261`) parse-fails any body that is
   not Clash YAML.

### UX

The deep-config surface (the `profile_routing` editors) is reachable only by opening an
existing profile. On a fresh install there are zero profiles, the first-run screen is an
empty list with no on-ramp, and there is nothing to configure until a YAML already exists,
which the user cannot produce. The lossless editor that is the fork's reason to exist is
unreachable because it only opens from a profile that does not yet exist.

This is a real, known gap. Upstream issues `chen08209/FlClash#128` ("Support v2ray share
links") and `#941` ("How to add vmess/hy2 links") were both closed "not planned".

---

## 3. Key technical finding: the core already parses share links

The initial assumption was that mihomo accepts only finished Clash YAML, so FlClash would
need a Dart-side protocol parser to turn a `vless://` link into YAML. That assumption is
false, and the correction is the whole unlock.

mihomo (clash.meta) natively ingests share links and base64 subscriptions through its
**proxy-providers** mechanism. The official mihomo wiki documents three accepted `content`
formats for a provider:

1. Clash YAML with a `proxies:` array,
2. raw URI share links (`vless://`, `vmess://`, `ss://`, `trojan://`, `hysteria2://`,
   `tuic://`, and more),
3. a base64-encoded v2ray subscription blob.

The in-core converter (`common/convert.ConvertsV2Ray`) decodes base64 and converts each
share-link scheme into a Clash proxy map.

Architectural consequence: generating a profile from a bare link does NOT need a Dart
protocol parser. We hand the pasted text to the core via a proxy-provider and the core
parses it. FlClash stays a pure Dart consumer of the libmihomo facade; this is config
composition in `lib`, no native change.

The one unknown this introduces is handled in section 18 (the Reality readback).

---

## 4. Pain thesis

The pain is not "FlClash can't import a bare link." That is the symptom. The pain is a
**trust collapse in the first thirty seconds, on the worst possible network, for the
person least able to recover from it.**

The real user: a person in Tehran or Moscow whose Instagram just stopped loading, who
messaged a friend, who got back a link and the words "paste this into the app." They have
no mental model of a profile containing proxies inside proxy-groups routed by rules
resolved through DNS. They have an activation artifact and a job: make the internet work
again before they give up. To them, this thing IS the VPN: one artifact, one working VPN,
like a streaming code. FlClash greets exactly this person with a hard wall built from
three rejections they will never understand, sitting behind an empty first run. They
paste, nothing happens, and within seconds they are in Hiddify or v2rayNG, which converged
years ago on one "+ to import from clipboard to connect" gesture. FlClash is the only
mihomo client that fails the universal paste gesture.

The second, deeper pain (the one the easy rivals do not solve): on a censored network the
failure that matters is invisible. A tunnel that handshakes but resolves DNS through the
state's resolver, or egresses IPv6 outside the tunnel, shows up in every rival's UI as a
confident green dot. The user feels protected and is not. For an at-risk user that is not
a bug, it is a danger.

The product's job is two-sided: remove every gram of friction from the happy path, and
refuse to ever lie about being connected. The first half is table stakes the fork
currently fails. The second half, a mandatory functional probe before the word
"Connected", is where this fork can be the honest client in a category full of optimistic
ones.

Sharp version: the user was handed a key and a promise and is standing in front of a
locked door holding both. Our job is to make the door not exist, and, once they are
through, to never tell them they are safe when they are not.

---

## 5. Personas

Six segments, overlapping. No invented percentages: the product refuses network telemetry,
so any "share" would be unverifiable forever. Sizes are honest qualitative tiers
(dominant / common / niche) derived from where the evidence exists (GitHub issue traffic,
TG/marketplace listings, self-hoster reports), not from a denominator we do not have.

| # | Segment | Tier | Artifact held | Tech level | "Done" means |
|---|---|---|---|---|---|
| 1 (golden path) | Paste-and-go, single artifact | dominant | "the link", form unknown to them; usually a sub-URL or base64 multi-node blob, sometimes a literal bare link | lowest | toggle green + a blocked site loads; never saw "profile" or "proxy-group" |
| 2 | Subscription-URL buyers (paid TG/marketplace) | dominant | one `https` sub URL with quota + expiry | low-mid | connected now AND, on later opens, honest proof the sub is healthy |
| 3 | Free-channel key rotators | common | stash of disposable keys + rotating base64 subs | low-mid | found a key that connects right now; swap speed is everything |
| 4 | Friend/relative-provisioned, toggle-only | common | nothing in their own hands; phone arrives configured; maybe a QR | lowest | one obvious switch, green = sites work |
| 5 | Self-hosters (3x-ui / Marzban / Remnawave) | niche | their own panel output: a VLESS+Reality link or sub | high | connects with the exact transport, and the client did NOT silently drop Reality |
| 6 | Clash-config power users | niche | full hand-authored clash/mihomo YAML | highest | their YAML loads unmodified, edits round-trip losslessly |

Design reading. Segment 1 is the target; the format-agnostic box is built for its behavior
(paste one opaque thing), and because that behavior most often carries a multi-node
subscription, the subscription path is the golden path, not a special case. Segment 2 forks
only on lifecycle (keep `QuotaBar`/`SubscriptionInfo`). Segment 5 is why the honesty gate
exists and the only consumer of the Reality readback. Segment 6 is why the generator must
never overwrite authored YAML.

---

## 6. The premise, reframed (artifact vs behavior)

The product owner's framing was "roughly half of users just want to paste a single vless
link and go." Adversarial verification against real evidence (forums, GitHub issues, TG
seller listings, self-hoster reports) confirmed the behavior and corrected the artifact:

- The behavior "paste one opaque thing and go" is plausibly about half. The intuition holds.
- The dominant artifact is the subscription URL, not a bare vless link. A bare single link
  is a minority artifact, concentrated in IR free channels and RU personal/self-hosted
  single-server setups. RU specifically is a genuine mix: commercial multi-node sellers
  trend to subscriptions (Happ/Marzban), while the large personal/self-hosted segment
  routinely ships a single vless link or QR.

Design implication: do not build a "vless link parser UI". Build a format-agnostic paste
box that the user fills without knowing what they hold, and fork the format internally. The
subscription path is the golden path; the bare single link is a trivial subset of it. The
"generate a profile from zero out of one vless link" capability remains core; the box must
simply also swallow subscriptions, because that is what most users actually hold.

---

## 7. Friction map

Today's funnel loses segment 1 entirely:

1. Receive artifact (link / QR / blob / sub-URL). They cannot classify it.
2. Open FlClash to an empty profile list with no on-ramp. Drop-off #1, the rage-quit point.
3. Find "+". It expects a URL. Paste `vless://...`, blocked at `isUrl`. Drop-off #2.
4. Paste a sub-URL instead. It routes to the HTTP GET. Sub host blocked by ISP, multi-second
   hang, generic `networkException`. Drop-off #3.
5. No node-count confirmation, no functional "it works."

What we remove: the empty dead-end first run; the `isUrl` rejection (classify and fork
before the GET); the format question (the box auto-detects, silently); the protocol
question (absorbed by `ConvertsV2Ray`); the routing/DNS/IPv6 questions (the region-safe
envelope answers them with no user choice); the node-pick question (single node = nothing
to pick, multi-node = auto delay-test + preselect fastest); the naming question (name from
`#label` / `Content-Disposition`); the "did it work?" ambiguity (a functional 204 probe,
not a green dot).

What we keep, deliberately and exactly once: the Android system VPN-permission dialog
(unavoidable, pre-explained). Nothing else interrupts the golden path. The whole golden
path is two user taps plus one system dialog.

---

## 8. Design principles

1. **Zero vocabulary on the golden path.** The words profile, proxy, proxy-group, node,
   server, subscription, rule, rule-provider, DNS, outbound never appear to segment 1,
   including in informational UI. Vocabulary is a power-user surface, revealed, never
   required.
2. **One decision maximum, the target is zero.** A well-formed artifact requires no choice.
   The only acceptable interruption is the OS VPN dialog. Every other "choice" on the happy
   path is a wrong default we failed to pick.
3. **Never show a dead tunnel as connected.** "Connected" is asserted only after a real
   request succeeds through the proxy (HTTP 204 via the existing delay-test infra), not
   after a handshake, not after `validateConfig` passes. The opposite of "verified" is an
   honest failure state, never a hidden one.
4. **Opinionated on safety because safety has no policy on the golden path.** The envelope
   is full-tunnel: everything egresses the proxy and all DNS resolves through it. There is
   nothing to decide because routing nothing-direct is the absence of policy, so DNS is
   plumbing, not policy.
5. **Region-neutral, therefore region-correct.** The artifact carries no region, so the
   envelope contains nothing wrong in any target region (IR/RU/CN): no public domestic
   resolver, no geo-DB fetch, no Reality-breaking sniffer. Correct everywhere by assuming
   nothing about here.
6. **Preserve the raw input, always.** A failed import never clears the box. The pasted
   string stays focused with a plain-language diagnosis. The user retries by editing, not by
   re-pasting from a clipboard they may have overwritten.
7. **The artifact is opaque, the state is legible in lay terms.** What the user reads is a
   name and an honest state in words they know ("Connected, 42 ms, verified"). Protocol
   identifiers (VLESS, Reality) are a seg-5 honesty signal one tap down, never on the
   seg-1 headline.
8. **Do not regress the segments we already serve.** Subscription users keep their quota UI,
   power users keep their lossless YAML untouched and their full editor reachable. The
   golden path is additive, never a flattening.

---

## 9. The golden path, screen by screen

Worked example (the hard case): a paid `https` subscription URL that resolves to about 8
nodes (a mix of vless+Reality, vmess+ws+TLS, shadowsocks) carrying `Subscription-Userinfo`
quota/expiry headers, on a censored network. The bare link is the easy subset of this.

UI strings below are the design reference; they are localized (the fork ships `arb/`),
so a RU user sees them in Russian.

### Screen A, first run (the missing on-ramp)

A single centered, action-first surface. The empty profile list is gone.

- Primary button (large): `Paste your key`. Subtext: `Paste the link, QR, or code your
  provider sent you.` (Note: "code", not "subscription". No taxonomy.)
- Secondary: `Scan QR`.
- Tertiary, quiet link: `I don't have a key yet`, leading to a short non-commercial
  explainer. We do not sell.

On open, the app silently inspects the clipboard. If it already holds a recognizable
artifact, the primary button becomes `Paste your key (1 found)` and a tap skips straight to
verifying (the Outline auto-insert pattern).

### Screen B, the one box (no classifier, no type-picker)

A single field, never a type-picker (Shadowrocket's #1 drop-off, avoided by construction).
Placeholder `Paste here`, clipboard auto-filled if detected. There is no live classifier
line: the box eats bare link, base64 blob, and sub-URL silently and forks internally,
because the user does nothing different between the three, so naming a taxonomy they cannot
use only leaks the banned words. No name field; the name comes from the artifact.

### Screen C, verifying (silent machinery, one honest spinner)

Full-bleed status, not a dialog. Copy progresses through states the user can feel:
`Setting up...` to `Checking your connection...` to `Almost there...`.

Underneath, in order: ingest (classify bare/base64/sub before any GET, fixing `isUrl`; for
a sub-URL, fetch with a short timeout and a blocked-host-aware error, not a generic hang),
persist the raw artifact to the per-profile sidecar, synthesize the region-safe full-tunnel
envelope over the converted nodes, hand to the pinned core, for multi-node delay-test all
nodes and preselect the fastest, then a functional url-test (HTTP 204) through the selected
node. The 204 is where we earn the right to say it works. If it fails, we go to the
honest-fail state, never to green.

### Screen D, the VPN permission (the one kept friction)

Before the OS dialog fires, a one-line pre-explain: `Android will ask to set up a VPN
connection. This is required and normal, tap Allow.` Then the system dialog, Allow,
biometric if set.

### Screen E, the "it's working" moment (functional, lay-language)

The connect control turns green and carries a functional, quantified, vocabulary-free
confirmation:

> **Connected**
> `42 ms, verified`

"verified" means a real request just succeeded through the tunnel: the honesty payload, in
a word a non-technical user trusts. The 42 ms is a real delay-test. The status-bar VPN icon
is a third independent signal (color is never the only signal).

Protocol identifiers live one tap down. Tapping the connection reveals a detail sheet:
`VLESS, Reality` (or `VMess, WS, TLS`), the node name, the quota line for subscriptions
(`Plan: 41 GB of 100 left, renews 12 Jul`), and for segment 5 the Reality readback verdict.
None of this is on the headline. There is no post-connect routing card: the dangerous "keep
banking/government sites direct?" popup is removed from the golden path entirely (it forced
a routing-policy decision on a persona with no mental model, and its label narrated the
user's gov-site browsing, a deanonymizing tell). Domestic-split exists only as an opt-in
region template in the power surface.

Tap count: "Paste your key" then "Allow". Two taps plus the system dialog. That is the
floor for this job, and we hit it.

---

## 10. Generated-profile spec (the region-safe envelope)

The from-zero generator produces a real, well-formed, editable mihomo config wrapping the
user's nodes. Every default is chosen so the config is correct in IR, RU, and CN
simultaneously, by assuming nothing about here.

```yaml
# --- Nodes: lossless, from the raw artifact ---
proxy-providers:
  zero:
    type: file                 # raw artifact persisted to the per-profile sidecar
    path: ./providers/zero.yaml
    # for a sub-URL the existing http path also writes the sidecar; type:file is the
    # single-bare-link / base64 case. Either way ConvertsV2Ray does protocol parsing.
    health-check: { enable: true, url: http://cp.cloudflare.com/generate_204, interval: 300 }

proxy-groups:
  - name: PROXY
    type: url-test             # multi-node: auto-pick fastest; single node: trivially one member
    use: [zero]
    url: http://cp.cloudflare.com/generate_204
    interval: 300
    tolerance: 50

# --- Routing: FULL TUNNEL, zero geo rules (so NO geo-DB is ever fetched) ---
rules:
  - MATCH,PROXY

# --- DNS: resolves THROUGH the tunnel; no domestic resolver; no plaintext leak ---
dns:
  enable: true
  enhanced-mode: fake-ip       # tunneled domains get a fake IP instantly; real resolution
                               # happens remotely at the proxy egress -> zero local DNS leak
  fake-ip-range: 198.18.0.1/16
  respect-rules: true          # DNS queries follow MATCH,PROXY -> egress the tunnel
  nameserver:                  # IP-literal DoH, reached OVER the tunnel:
    - https://1.1.1.1/dns-query      # IP literal -> no bootstrap hostname to resolve
    - https://8.8.8.8/dns-query      # poisoning of these IPs is on the LOCAL path; tunneled, it's clean
  proxy-server-nameserver:     # resolves ONLY the node's own hostname (the IP the ISP already sees)
    - system://                # existing v0.15.1 hardening; reveals nothing new
  # NO default geo/fallback resolver, NO AliDNS/DNSPod, NO bare 8.8.8.8/1.1.1.1 plaintext.

# --- Sniffer: OFF on full-tunnel (nothing to route -> nothing to sniff) ---
# Explicitly NOT enabled. mihomo's sniffer defaults override-destination:true, which
# with Reality would redirect to the decoy SNI host and kill the tunnel. Never enabled here.
# tls-fragment is likewise NEVER set (it corrupts the Reality ClientHello).

# --- IPv6: leak-blocked, underlay preserved ---
ipv6: true                     # allow node-endpoint resolution over v6 (v6-only carriers, AAAA-only nodes)
tun:
  inet6-address: []            # route-level v6 blackhole for TUNNELED traffic only
# i.e. "IPv6 off" means "don't leak v6 outside the tunnel", NOT "tear down the v6 stack".

# --- Geo data: never fetched ---
geo-auto-update: false
# geox-url left unused because zero geo rules exist. No geoip.dat/geosite.dat is loaded,
# so first connect on a GitHub-blocked network NEVER stalls on a geo-DB download.

find-process-mode: strict      # PROCESS-NAME via VpnService permission, not /proc/net/tcp (mobile)
```

The minimal-vs-opinionated decision, stated:

- Opinionated (non-negotiable, because omission fails invisibly): full-tunnel `MATCH,PROXY`,
  fake-ip, DNS through the tunnel, no domestic resolver, no geo-DB, no sniffer, no
  tls-fragment, v6 leak-block. There is exactly one safe answer per region, so we choose it
  and never ask.
- Minimal (we add nothing else): no carve-outs, no `GEOSITE`/`GEOIP` rules, no domestic
  split, no per-app ACL on the golden path. Anything the artifact does not encode, we do not
  invent.

Per region the generated default is identical across IR/RU/CN, which is the point.
Region-specific behavior (a domestic-split template) exists only as an explicit opt-in
template in the power surface, which bundles its own slim geoip/geosite inside the APK with
`geo-auto-update: false`, so even the opt-in path never fetches a DB over a blocked network.

Exact key names/values are validated against the pinned core (mihomo v1.19.26 in
libmihomo-android v0.1.4) during implementation; the postures above (fake-ip, IP-literal
DoH over tunnel, no geo rules, sniffer off, v6 route-blackhole) are the load-bearing
decisions.

---

## 11. Honesty gate, failure and trust UX

The honesty thesis is only real if the failure path is as disciplined as the success path.
Green is earned by a 204, or it is not shown.

Implemented (0.16): `decideVerifyStatus` maps the through-tunnel `request.checkIp()` probe to
verified/failed (a null result or a REJECT default route is an honest failure, never a false
green); `QuickStartVerifyCard`/`QuickStartVerifyOverlay` render the states below and wire the
`quickStart*` l10n keys. The fail screen and its two CTAs are exactly the design that follows.

The single v1 failure state: if the functional url-test fails after the handshake, full-bleed:

> **Couldn't reach the internet through this key**
> `The key connected, but no page would load.`
> `[Try again]   [Use a different key]`

- The raw artifact is preserved in the box (Principle 6). The user edits/retries, never
  re-pastes from a lost clipboard.
- For a multi-node sub, "Try again" retests the next-fastest node before failing. Multi-node
  gives free retries.
- A sub-URL fetch that was blocked (host unreachable) gets a specific, different diagnosis
  (`Your provider's link couldn't be downloaded on this network`), because the fix differs
  (a blocked sub host vs a dead node).

The trust contract, enforced for everyone:

1. The word "Connected" implies a real request succeeded through the tunnel. Never asserted
   on handshake or `validateConfig` alone.
2. No silent insecurity. We never connect-anyway past a known-bad signal without showing it.
   In v1 the only gate is the 204, so there is nothing to silently pass; the Reality
   readback is an inspector, not a hidden override.
3. No telemetry as the price of trust. Nothing about the user's failure, artifact, or region
   leaves the device.

The old binary risk-consent screen (connect anyway despite a degraded readback?) is cut from
v1; it sat a niche-segment concern on everyone's critical path. If a future split mode
reintroduces a real degraded-vs-safe choice, it returns as a power-surface setting, never a
golden-path popup.

---

## 12. Progressive disclosure

The from-zero output is a real, well-formed, editable mihomo config, not a black box. The
mihomo vocabulary is hidden by default and revealed in layers:

- Layer 0 (segment 1): "your key", "Connected, 42 ms, verified". Zero mihomo words, ever.
  This is the entire golden path.
- Layer 1 (connection detail sheet, one tap down): node name, protocol tokens
  (VLESS, Reality / VMess, WS, TLS), quota line, Reality readback verdict. Read-only, mostly
  lay language; the protocol tokens are honesty signals, not controls.
- Layer 2 (the power surface, the fork's reason to exist): the full 0.16 `profile_routing`
  lossless editors (proxies, proxy-groups, rules, rule-providers, DNS), reachable from the
  profile exactly where a power user expects. The synthesized envelope is visible and
  editable here as ordinary YAML; the domestic-split region templates are opt-in here.
  Editing round-trips losslessly and survives sub updates.

One artifact, three audiences, one config underneath. The simplest user never descends past
Layer 0; the power user lands in Layer 2 without the golden path having shown them a single
primitive. The vocabulary is a destination, never a toll. This is what rivals lack: they
treat the subscription as an opaque blob, while this fork offers paste-and-go for novices
and byte-preserving GUI editing for power users on the same profile.

---

## 13. Segmented flows

- Seg 2 (subscription buyers): same paste, same verify, same green. The only addition is
  lifecycle, surfaced as legible state not vocabulary: the quota line on the connection
  detail sheet and a quiet secondary line on later home opens. Built on the existing
  `QuotaBar`/`SubscriptionInfo`. Silent day-31 death is prevented by showing days/GB on
  every open.
- Seg 3 (free-channel rotators): v1 serves them with the same paste box. The dedicated
  paste-test-discard fast-swap loop is named backlog, not silently included.
- Seg 4 (friend-provisioned, toggle-only): v1 gives one obvious toggle and the "verified"
  state. Zero-comprehension QR/deep-link re-import is named backlog.
- Seg 5 (self-hosters, the canary): they paste their own Reality link, connect, then tap
  into the detail sheet to read the Reality readback verdict ("Reality parameters preserved
  by the core"). This is the only place the `readProxyInfos` pbk/sid/fp/flow check is
  surfaced, because it is the only segment for which it is meaningful. It is an inspector,
  not a gate; it never blocks or forks the golden path.
- Seg 6 (clash-config power users): a pasted full YAML is detected and loaded unmodified.
  The generator never wraps or overwrites an authored config. The golden-path envelope is
  applied only to from-zero artifacts.

The golden path is additive. Each other segment is served by the same flow plus legible
state (2, 5), the same flow as-is (4, 6), or an explicitly deferred enhancement (3, 4
re-import). None of them bends the two-tap happy path.

---

## 14. Competitor landscape

Almost the entire clash family fails the bare-link gesture. Only Karing and Hiddify do it
well, and both run sing-box, not mihomo. No mihomo client nails paste-and-go, which is the
opening.

| Client | Core | Bare share link | Subscription | Taps to connect |
|---|---|---|---|---|
| FlClash (today) | mihomo | no | clash YAML only | stuck |
| Clash Verge Rev | mihomo | partial (node into existing profile) | clash YAML | 7-11 |
| Mihomo Party | mihomo | no (clash:// only) | clash YAML | 5-9 |
| ClashMi | mihomo | unclear for single | clash / base64 / sing-box | ~5 |
| Karing | sing-box+ | yes (single Link/Content field) | all formats | ~4 |
| Hiddify | sing-box | yes (+ hiddify:// scheme) | all formats | ~5 |

Patterns worth copying: Karing's single Profile Link/Content field that swallows URL / raw
URI / YAML / base64 in one box; Karing's V2Ray batch; Hiddify/Karing pre-selected fastest
node; Hiddify's home subscription card (we already have `QuotaBar`); Karing's gallery-QR;
Karing Beginner mode; Hiddify region toggle; Hiddify deep links. Patterns rejected:
Hiddify's auto-clipboard-on-launch banner (fires the OS clipboard toast every launch,
off-brand for a no-telemetry fork; we gesture-gate the read instead), runtime `type: http`
provider on cold start (fetched DIRECT through the censored path), embedded Sub-Store, dual
core, CN-default DNS, default geo databases, WARP, built-in updater, telemetry.

The cross-domain gold standard for "paste an opaque credential, become fully configured" is
Outline (`ss://` access key), Tailscale (auth key), WireGuard (QR), and eSIM activation:
one ingest, near-zero questions, a single "it's working now" confirmation. The golden path
above is modeled on that bar.

---

## 15. Implementation

FlClash stays a pure Dart consumer of the libmihomo facade. Everything here is config
composition in `lib` (`task.dart`, providers, profile YAML), no native change.

### Mechanism

The static payload (raw link, base64 blob, or already-downloaded sub body) is written to a
sidecar file in the per-profile providers dir, and a `type: file` proxy-provider reads it;
the core's `ConvertsV2Ray` does the conversion. This is the documented file-content
conversion path. `type: inline` (raw-uri) is not relied upon (a different, unproven code
path, and inline providers are static). A runtime `type: http` provider is forbidden on
cold start because `_makeRealProfileTask` fetches it DIRECT (`task.dart:82-176`), through
the exact censored path we are escaping.

The host already exists: `Profile.type` returns `file` when the url is empty
(`lib/models/profile.dart:147`), `realAutoUpdate` is false for an empty url, and a
per-profile providers-dir lifecycle exists (`getProvidersDirPath`, `clearEffect` deletes
it). The generator writes the raw artifact to a sidecar under that dir, synthesizes the
wrapper YAML referencing it, and reuses the existing `saveFile()` path. `saveFile` stays a
dumb validate-and-write gate; the wrap happens at import time in the controller. A
quick-start profile's refresh re-downloads the body and overwrites the sidecar file only,
so the synthesized config and any later Layer-2 edits are byte-untouched.

The enabling fix is classify-before-GET: the box forks bare/base64/sub-URL internally before
any network call, which ends the `isUrl` rejection and the dio HTTP-only assumption, so a
blocked sub host yields a specific error instead of a generic hang.

### File inventory

New:
- `lib/pages/onboarding.dart`: OnboardingView, gesture-gated clipboard, the recovery state.
- `lib/services/quickstart_config_service.dart`: the only genuinely new logic; classify,
  endpoint-authority extractor (for the conditional DNS), sidecar materializer, synthesize.
- `lib/profile_routing/proxy_spec.dart`: Phase 2 only (single-server CRUD / readback
  fallback).

Modified:
- `lib/views/profiles/add.dart`: a top "Paste link / subscription" entry that accepts any
  scheme.
- `lib/common/string.dart:8`: add `isShareLink`/`isImportable` + `shareLinkSchemes`; forms
  validate `isImportable`.
- `lib/controllers/profiles_controller.dart` (the wrap site, around :115) + a new paste/scan
  handler: branch share-link/base64 to local synthesize + saveFile, subscription URL to
  dio-download + re-sniff, then the node-count gate.
- `lib/models/profile.dart` `saveFile` (around :256): left a dumb gate.
- `Profile.update`/refresh: overwrite the sidecar only for quick-start profiles.
- `lib/common/picker.dart:61` and `lib/pages/scan.dart:48`: relax `BarcodeType.url` to
  accept raw-text barcodes and route the decode through the sniffer (a vless QR currently
  dies here).
- `profiles.dart` + dashboard: onboarding CTA on empty, surface `QuotaBar`.

Reused as-is (Layer 2, the 0.16 deep-config): `profile_routing` editors, `routing_hub.dart`,
`proxy_groups.dart`, `providers.dart` (lossless ProviderSpec, which later edits the
quick-start `type: file` provider), `sub_rules.dart`, `routing_rules_editor.dart`,
`rule_block_builder.dart`, `config/dns.dart`. Post-import latency reuses the existing
delay-test + selected-map.

### The Reality readback (demoted to inspector)

`validateConfig` proves structure only. A Reality-stripped proxy is still structurally
valid, so it would connect and fail. The readback (`readProxyInfos` reads back
`reality-opts.public-key`, `short-id`, `client-fingerprint`, `flow`) confirms the node is
real. Because most subscriptions are vmess/ss/trojan with no Reality fields, the readback is
NOT the golden-path gate; the golden-path gate is the transport-agnostic 204. The readback
is surfaced only on the seg-5 detail sheet as an inspector.

---

## 16. Roadmap

| Phase | What | Effort | Reuses |
|---|---|---|---|
| 0 (ship first) | Format-agnostic paste/clipboard/QR/file import to a `type: file` sidecar + synthesized region-safe envelope; onboarding screen; node-count gate; auto fastest-node; 204 honesty gate; Connect | M | `profiles_controller`, `saveFile`, dio, delay-test, `QuotaBar`, `picker`/`scan` (relaxed guard) |
| 1 | Beginner mode (Connect + auto), recovery polish, deep-link re-import | S | OnboardingView, QuotaBar |
| 2 | Single-server GUI CRUD via a Dart `ProxySpec` codec (also the readback fallback parser) | M-L | `group_spec`/`provider_spec` patterns, `providers.dart`, yaml_edit |
| 3 | Opt-in region presets + single-toggle geo-bypass/ad-block, downloaded only after a tunnel exists | M | `routing_rules_editor`, `rule_codec`, `sub_rules` |
| 4 | DNS GUI over `config/dns.dart` with the hardened defaults as template | M | `config/dns.dart` |
| 5 | Full routing/group/sub-rule GUI promoted to first-class, per-app tun editor | L | `routing_hub`, `proxy_groups`, `providers`, `rule_block_builder` |
| 6 | Operator deep links `flclash://import?url=...#name` | S | existing clash:// intent filters, the Phase-0 sniffer |

---

## 17. Scope: v1 vs named backlog

v1 (ship this, nothing more):

- One format-agnostic box: bare link / base64 / sub-URL / QR to silent ingest (classify
  before GET, fix `isUrl`).
- Region-safe full-tunnel envelope (section 10).
- Multi-node delay-test + preselect fastest.
- Functional 204 honesty gate to green-or-honest-fail.
- Keep (do not regress): `QuotaBar`/`SubscriptionInfo` http-sub path; seg-6
  unmodified-YAML load; the Layer-2 editors.

Named backlog (explicitly deferred, not silently included):

- Screen-B live classifier line: cut (vocabulary leak, zero decision value).
- Post-connect banking/gov routing card: cut (forced policy decision + deanonymizing label).
- Seg-3 paste-test-discard fast-swap loop: deferred.
- Seg-4 zero-comprehension QR/deep-link re-import: deferred.
- Binary degraded-consent screen: cut (replaced by the single honest-fail state).
- Domestic-split region templates (APK-bundled geo data): deferred to the power surface,
  opt-in only.
- Reality-field readback as a gate: cut; retained only as the seg-5 inspector.

v1 is one box, one envelope, one gate, one honest failure. Everything else is a labeled v2.

---

## 18. Risks

- **P1 (load-bearing, blocks Phase 0): Reality survival on the pinned core.** The fork's
  core is a SHA+GPG-pinned prebuilt `libclash.so v0.1.4` with no Go source in-repo. It is
  unverified whether this pinned converter maps Reality fields, and `validateConfig` passes
  even on a Reality-stripped proxy. Mitigation: a semantic read-back test against the pinned
  AAR before any UI work (feed a real 3x-ui Reality link through the file-provider, assert
  the fields survived via `readProxyInfos`). If it fails: bump the pinned core to a verified
  version (SHA+GPG re-pinned, via `dart setup.dart android`, not a wrapper hack), or pull the
  Phase-2 Dart `ProxySpec` parser forward to synthesize inline `proxies:` with explicit
  `reality-opts`. Do not ship Phase 0 on the converter for the Reality format until green.
- Split-path conversion: single-link and base64-sub file-provider conversion are different
  code paths; TDD each independently.
- Zero-node dead tunnel: the mandatory `readProxyInfos` node-count >= 1 gate before the
  url-test; 0 nodes routes to the recovery state, never a green tunnel.
- Endpoint DNS for a hostname node: DoH:443 is SNI/IP-blocked in IR; resolve a hostname
  endpoint with plain UDP/53 against multiple IPs, omit endpoint DNS for IP literals, and
  surface a distinct "couldn't resolve server address" error.
- Edit loss on refresh: wrap only at import time; refresh overwrites the sidecar only;
  `saveFile` stays a dumb gate.
- Geo-DB download on first run: removed by using explicit IP-CIDR LAN rules and zero geo
  rules.
- Clipboard toast / privacy: gesture-gated read on button press only.
- fake-ip app breakage: `fake-ip-filter` covers common offenders (NTP, localhost, *.lan);
  extensible per region.
- Build constraints: any core bump follows the fork's SHA+GPG AAR pinning and
  `dart setup.dart android` with dart format + DCM + detekt gates.

---

## 19. Measurement plan

No network telemetry, so activation is measured on-device, opt-in, never transmitted, plus
external proxies.

- Activation metric (the one that matters): paste to verified-connect completion rate,
  counted by a local opt-in counter (`imports_attempted`, `imports_verified`,
  `imports_honest_failed`, broken down by ingested format) that the user can view and wipe in
  Settings and that never leaves the device. Default off; a one-line opt-in ("Help me see if
  setup is working, stays on this phone, sent nowhere").
- Honesty metric: ratio of `imports_honest_failed` to `imports_verified`, proving the 204
  gate catches dead tunnels. A near-zero failed count is suspicious (the gate isn't biting),
  not good.
- External proxies (no instrumentation): GitHub issue volume tagged import/paste failures
  should fall toward zero post-v1; app-store / TG-channel review sentiment on "couldn't add
  my key"; the seg-5 self-hoster canary (continued clean Reality-integrity reports).

Success: import-failure issues dry up, the local verified-rate is high, and the honest-fail
count is non-zero and proportional.

---

## 20. Changelog: critique to fix

The product design survived an adversarial review; the load-bearing corrections:

| Critique | Fix |
|---|---|
| Invented percentages, unverifiable with no telemetry | Dominant/common/niche tiers; all percentages deleted; only ethical measurement is the opt-in on-device counter |
| Golden path optimized for the minority bare-Reality link | Worked example is now a multi-node subscription URL; bare link is the subset |
| Screen-B classifier line leaks "subscription/servers" | Classifier line deleted; box ingests silently |
| Post-connect banking/gov card forces a routing decision + dangerous label | Card removed from golden path; domestic-split is opt-in power-surface only |
| "VLESS, Reality, 42 ms" leaks protocol vocab to seg 1 | Headline is "42 ms, verified"; protocol tokens moved behind a tap |
| DNS-over-tunnel "with what resolver?" is a regional leak | No domestic resolver; fake-ip + IP-literal DoH over the tunnel; `proxy-server-nameserver: system://` for the node hostname only |
| Geo carve-outs trigger a geo-DB fetch on a blocked network | Zero geo rules, no DB ever loaded; opt-in templates bundle slim geo data in-APK |
| Sniffer (`override-destination:true`) breaks Reality; tls-fragment corrupts ClientHello | Sniffer OFF on full tunnel; tls-fragment never set |
| IPv6 "off" tears down the v6 underlay on v6-only carriers | v6 leak-blocked at TUN/route level only; underlay preserved |
| Reality-field readback over-fit to the canary, on the seg-1 critical path | Golden-path gate is the transport-agnostic 204; readback demoted to seg-5 inspector |

---

## 21. Provenance

This document synthesizes two adversarially-verified multi-agent research passes run on
2026-06-28 against the recovered 0.16 branch (`recovered/per-app-routing-wip-2026-06-26`,
v0.16.0-rc1):

1. Code + interface + competitors + protocol: established that the mihomo core natively
   parses share links (the unlock), inventoried the UI-config surface and the three rejection
   layers, and produced the technical mechanism and roadmap.
2. User pain + zero-to-profile product design: segmented users, mapped how vless links
   actually reach them, defined the region-safe envelope, and produced the golden path,
   honesty gate, and progressive-disclosure model.

Both passes used independent verifier agents; the corrections they forced are in the
changelog above. Key external grounding: the official mihomo wiki (proxy-providers content
formats), upstream issues `chen08209/FlClash#128` and `#941`, and competitor docs for
Karing, Hiddify, Clash Verge Rev, Mihomo Party, and ClashMi.

---

# Part II: The routing constructor (profile-settings redesign)

Status: implemented in v0.16.0-rc3, including the server layer (the old II.10 boundary is lifted).
Both parity paths are proven at config level by tests: (a) loading a full power-user profile
(multi-node exit + subscriptions + fallback/url-test/provider-filter mesh + full routing) is
recognized and round-trips verbatim (`test/services/profile_parity_test.dart`), the clean groups
modeled as Auto/Failover/Manual and the filter-split mesh preserved raw under Advanced; (b) a
from-zero pasted vless is configured through the model into that same doctrine
(`test/services/end_to_end_journey_test.dart`). The Servers screen imports by link/subscription
(auto-detect), lists nodes+subscriptions with latency, picks the exit (Auto-fastest / server /
smart group), and builds Auto/Failover/Manual groups — no clash grammar on any primary screen.
Shipped earlier (v0.16.0-rc2): the domain model + lossless bidirectional
bridge (`lib/services/routing_model.dart`), the localized Catalog + country table
(`lib/services/routing_catalog.dart`), the persistence controller
(`lib/controllers/routing_constructor_controller.dart`), and the constructor UI
(`lib/views/profiles/routing_constructor.dart`: Lists with all four sources + a Catalog browser,
a Scenarios flat-row editor, the ad-block toggle, the unlisted-apps allow/block segment, a
one-tap "RU smart split" preset, and the Advanced gate over the raw hub). Part I's synthesizer is
refactored onto the shared writer (`applyQuickStartRouting`), so paste-and-go and edit share one
mechanism. Backed by 30 unit tests (bridge round-trip on a sanitized reference profile,
idempotence, from-zero == edit, catalog lookups) plus the full green gate set (dart format,
analyze --fatal-infos, DCM check-unused, detekt, 266 tests). Remaining polish (not blocking):
re-skinning the Apps step-2 vocabulary to plain intents (currently links to the existing
AppRoutingView), a dedicated Server picker, themed empty-state illustrations, constructor widget
tests, and the on-device end-to-end gate. Locked scope decisions: full constructor in v1; all four
List sources in v1 (built-in Catalog / by URL / paste / by country); no manual node editor in v1.
Grounded in a 7-reader multi-agent map of every existing profile-settings editor plus a full read
of a real in-use power-user profile (provenance at the end of this part).

## II.1 The job

Part I gets a censored-network user from a pasted artifact to a verified full-tunnel connection
with zero vocabulary. Part II is the next screen: the same user opens the profile and shapes
routing as a plain-language constructor — never touching YAML, mihomo rule syntax, proxy-groups,
`GEOSITE`/`GEOIP`/`PROCESS-NAME`/`RULE-SET`, or the words "sub-rule" / "provider".

It is NOT a fixed menu of presets. The user builds from scratch: connects their own lists (by
URL or by pasting domains), composes their own routing scenarios from those lists, and assigns
them to apps. Pre-seeded defaults exist only as starting content already sitting in the library,
never as the ceiling. The reference target — a real power-user mobile profile an ordinary user
should be able to recreate ~80% of with ~20% effort — is the validation bar (section II.11), not
a hardcoded template.

## II.2 The load-bearing principle: no magic values

The single hardest rule, the one every screen is measured against:

> Every value the user sets is a CHOICE from an enumerable set the app already knows. There is
> no field where the user must type a value they have to know — a geosite category, a country
> code, a domain TLD, a provider `behavior`/`format`, a group or rule target. Free text is
> allowed in exactly two places, and both are the user's OWN content, not knowledge of mihomo:
> a name they give their own list/scenario, and a URL or domain list they paste.

The "available options" come from three sources the app enumerates:

1. **The app-shipped Catalog** — a browsable, versioned, localized library of human-named
   matchers (Ads, Russian sites, Russian banks, YouTube, Telegram, Netflix, …), each backed by a
   public rule set whose name the user never sees or types.
2. **What already exists in the profile** — servers, lists, scenarios, apps — picked by
   reference (shown by name/icon), never typed.
3. **System / built-in enumerations** — the installed-app list (icons + names) and a country
   picker (flags + names) for by-IP matching.

Anything not in the Catalog is added by the user's own source (paste a URL / paste domains),
never by knowing a mihomo identifier.

## II.3 Architectural verdict: the engine is done

Unanimous across all seven readers: the persistence + validate + apply backbone is clean,
lossless, headless, and already exposes constructor-grade verbs. It is reused 100% with zero new
native code. The redesign is a human-language front + a bidirectional model<->YAML bridge over
the existing backend, not a rewrite.

| Layer | What it gives |
|---|---|
| `ProfileRulesDocument` (`yaml_rules_io.dart`) | lossless yaml_edit round-trip; preserves every unmodeled key + comments |
| `_writeValidatedApply` (`app_routing_controller.dart:311`) | validate -> commit -> hot-apply; file untouched on validation error |
| `aclFromTunYaml` (`config.dart:128`) | `tun.include-package` -> whitelist -> `VpnService.Builder` allow-list; "which apps enter the VPN" already works |
| `GroupSpec` / `ProviderSpec` / `rule_codec` | lossless codecs; generated strings round-trip and survive subscription refresh (`reapply.dart`); unmodeled grammar preserved read-only via `PassthroughRule` |
| controller verbs | `setAppMembership`, `setTunnelMode`, `setAppTarget`, `withSubRules` / `withRules` / `withProxyGroups` / `withIncludedPackages` |

## II.4 What is wrong with every current editor

- **Total YAML leakage.** Every editor is a 1:1 skin over mihomo grammar: `DIRECT`/`REJECT`/
  `GLOBAL`, `GEOSITE`, `PROCESS-NAME`, `RULE-SET`, "sub-rule", "provider", group types
  `url-test`/`fallback`/`relay`, regex member filters, provider `behavior`
  (domain/ipcidr/classical) and `format` (yaml/text/mrs), `AND`/`OR`/`NOT`, `src`/`no-resolve`,
  raw `serialize()` rule lines in monospace, "Open YAML" as a first-class action.
- **Three competing rule surfaces** write the same `rules:` with no precedence model: global
  Added rules, the per-profile Override overlay, the real `routing_rules_editor`. The Override
  overlay is the weakest (target hard-limited to DIRECT/REJECT/MATCH, cannot name a proxy-group)
  yet also exposes a JavaScript "script" mode and a full-config YAML preview on its primary path.
- **The routing hub presents five clash-noun siblings of mixed audience** (App routing =
  consumer; Proxy groups / Sub-rules / Providers / raw rules = expert) with no separation; the
  layperson whitelist control is five taps deep while the raw YAML editor is one tap away.

## II.5 The object model (human entity -> engine primitive)

Six human entities, each mapping losslessly onto an existing primitive:

| Human entity | What the user does | Engine primitive |
|---|---|---|
| **List** | a named set of sites/IPs to match; pick a backing kind (below) | a rule-provider, a built-in geosite reference, inline domains, or a GEOIP country |
| **Destination** | where matched traffic goes: Via VPN / Direct / Block | rule target: the VPN group / `DIRECT` / `REJECT` |
| **Rule** | one row: List -> Destination | a `rules:` / `sub-rules:` line (`RULE-SET,<list>,<dest>`, etc.) |
| **Scenario** | an ordered set of Rules + a default Destination | a named `sub-rules:` entry |
| **App** | an installed app -> a Scenario, or a simple mode | `tun.include`/`exclude-package` + per-app `PROCESS-NAME -> sub-rule/target` |
| **Server (exit)** | which node/group the VPN uses; ordinary user picks "Auto (fastest)" or one | `proxies:` / `proxy-groups:` (topology stays Advanced, see II.10) |

A **List is a named matcher with four backing kinds**, all chosen from a set, never typed:
- **from the Catalog** — a built-in public geosite set, picked by human name;
- **by URL** — the user pastes a link to their own rule set; behavior/format are auto-detected,
  never asked;
- **by paste** — the user pastes domains/IPs, one per line;
- **by country** — a country picker -> GEOIP (e.g. "Russia" -> `GEOIP,RU`).

This unification is what the reference profile forced: its smart-split scenario mixes
`RULE-SET`, `DOMAIN-SUFFIX,ru/su/xn--p1ai`, and `GEOIP,RU` in one ordered list, so "Russian
TLDs" and "Russia by IP" must be first-class Lists too, not special cases.

## II.6 Magic value -> picker (the no-magic rule, applied)

| Where the user used to need to KNOW | Now a pick from |
|---|---|
| a geosite set name (`category-bank-ru`) | the browsable Catalog ("Russian banks") |
| a country code (`GEOIP,RU`) | a country picker (flag + name) |
| Russian TLDs (`.ru`/`.su`/`.xn--p1ai`) | a built-in "Russian domains" List |
| a list's `behavior`/`format` | auto-detected on fetch; fallback human question only ("domains or IP addresses?") |
| a destination (`DIRECT`/`VPN`/`REJECT`) | a three-way segment (Direct / Via VPN / Block) |
| the VPN exit / a server or group name | the list of existing servers and groups, by name |
| an app (`PROCESS-NAME,com.x`) | the installed-app list (icon + name) |
| a scenario for an app | the list of existing scenarios |
| rule order (first-match) | not typed, not explained; the app owns precedence, dangerous reorders are guarded |

Free text only: a name the user gives their own List/Scenario, and a URL or domains they paste.

## II.7 The Catalog is a real deliverable, not four seed rows

Because every match value is a pick, the Catalog must be a real browsable library: a curated,
versioned, localized (EN/RU/JA/ZH) map of human names + icons -> public rule sets — a useful
subset of MetaCubeX meta-rules-dat geosite, the common GEOIP countries, and a few well-known
blocklists. The user browses "what can I match?" and taps; anything missing is added by
URL/paste. Pre-seeded content (a "Russia" bundle and a "Smart split" scenario) is just the most
common picks already added, fully editable and removable — so the reference profile is
reproducible by tapping, never by knowing that `category-bank-ru` exists. The underlying set
data is fetched at runtime as ordinary rule-providers, only after a tunnel exists, never over the
blocked cold path.

## II.8 The bridge: recognize, don't rebuild

The constructor reads and writes through the lossless backend, and on an imported power-user
profile it is read-mostly:

- **Recognize** modeled structures and let the user edit them in human terms: the load-bearing
  `VPN` group is recognized as "the exit" (never renamed — its name is the target of every
  per-app rule), an existing smart-split-shaped `sub-rule` is adopted as the "Smart split"
  scenario (not duplicated), rule-providers become Lists, per-app `SUB-RULE`s become App
  assignments, a top-level `RULE-SET,ads,REJECT` becomes the "Block ads" toggle, a terminal
  `MATCH,REJECT` becomes "block unlisted apps".
- **Preserve verbatim** everything not modeled: DNS / fake-ip / sniffer hardening, anti-loop
  DIRECT rules, `GEOIP,private`, QUIC plugs, app-companion-API carveouts, and the entire
  multi-group failover topology. These round-trip byte-for-byte and surface only under Advanced.
- **Mark app-generated artifacts** (a name marker) so the reverse reader never mistakes a power
  user's hand-authored rule for a preset and clobbers it; unrecognized shapes are shown as
  "Custom / Advanced", never silently rewritten.

## II.9 One universal mechanism: building new == editing existing

Creating a fresh profile from a pasted link/subscription (Part I) and refining an existing
profile (Part II) are NOT two code paths. They are one mechanism with two entry points:

- **one model** — the Lists / Scenarios / Apps / Server object graph (II.5);
- **one bridge** — read any profile -> model, write model -> YAML losslessly (II.8);
- **one writer** — `_writeValidatedApply` (validate -> commit -> hot-apply).

"Create new from a link, prefilled with defaults" = seed an empty model with the default Lists +
the "Smart split" Scenario + sensible app assignments, attach the pasted node as the Server, then
materialize through the same writer. "Edit existing" = read the profile into the same model,
mutate, materialize through the same writer. Part I's synthesizer is refactored to a thin caller
that seeds the model and writes; it keeps no separate YAML-assembly logic of its own.

Consequences:
- The default prefill is just one Preset applied to a fresh model; the identical Preset is
  one-tap-applicable to any existing profile.
- Every screen operates on the model identically whether the profile was born from a paste or
  imported hand-authored; there is no "new-profile mode".
- A fix in the writer fixes both paths; a List kind added is available in both; no drift.
- The honest-fail + validate + revert contract is one pipeline (Part I's 204 gate and the
  constructor's `validateConfigWithData` are stages of the same flow).

This is the lazy-architect win: one seam (model + bridge), two doors (paste / edit), zero
duplicated assembly.

## II.10 The boundary: what the constructor democratizes

The constructor makes Lists -> Scenarios -> Apps human and from-scratch buildable (the actual
request). It does NOT democratize server topology. A real power-user exit is a multi-group
failover mesh (manual pins, url-test/fallback tiers, provider-backed filter groups, relay and
TURN fallbacks); an ordinary user sees only "VPN exit: Auto (fastest) / pick one", while the mesh
is preserved and edited only under Advanced. Democratizing routing-by-lists is the goal;
democratizing a failover mesh is not.

## II.11 Validation against a real profile

A full read of a real in-use power-user mobile profile confirms the model is reverse-engineered
from how the file is already structured, not imposed:

| Real structure | Constructor entity |
|---|---|
| `tun.include-package` whitelist | Apps "in VPN" set |
| per-app `SUB-RULE,(PROCESS-NAME,…),vpn-app-route` | App -> "All via VPN" scenario |
| per-app `SUB-RULE,(…),browser-route` | App -> "Smart split" scenario |
| the `browser-route` sub-rule (ordered RULE-SET / DOMAIN-SUFFIX / GEOIP -> DIRECT/VPN + default) | a Scenario, exactly |
| ~17 rule-providers (MetaCubeX `category-*` + a runetfreedom blocklist) | Lists |
| top-level `RULE-SET,ads,REJECT` | "Block ads" toggle |
| terminal `MATCH,REJECT` | "Unlisted apps: block" (fail closed) |
| the load-bearing `VPN` select group atop a failover mesh | the Server exit (mesh stays Advanced) |
| DNS / fake-ip / sniffer, anti-loop, companion-API carveouts | preserved verbatim, Advanced only |

The strains the profile exposed are resolved above: a List is more than a rule-provider (II.5,
four backing kinds); a pasted URL is ambiguous between a server-subscription and a rule-list, so
the two live in different sections (Servers vs Lists) and are auto-detected; the exit is a tree,
kept under Advanced (II.10).

## II.12 The screens

```
LISTS                  SCENARIOS               APPS
 Ads           [+]      Smart split     [+]     Telegram  [Through VPN v]
 Russian sites          | Ads      -> Block      Chrome    [Smart split v]
 Russian banks          | RU sites -> Direct     Sberbank  [Bypass VPN  v]
 Blocked in RU          | Blocked  -> Via VPN     Game      [Block       v]
 + add list             | default  -> Via VPN
   from Catalog
   by link              + new scenario          WHAT TO BLOCK
   paste                                         Ads & trackers   [ on ]
   by country
                                                UNLISTED APPS
                                                 ( Allow direct | * Block )

                                                SERVER
                                                 Auto (fastest)  [ change ]

                                                Advanced (power users)  >
```

Per-app intent -> compilation:

| Intent chip | Compiles to |
|---|---|
| Through VPN | include-package + app -> the VPN exit group |
| Smart split (or any user scenario) | include-package + app -> the chosen scenario's sub-rule |
| Bypass VPN | not in tunnel (`exclude-package`) |
| Block | `PROCESS-NAME,<pkg>,REJECT` |

"Unlisted apps -> Block" = whitelist + `MATCH,REJECT` (fail closed). The ad-block toggle and the
unlisted-apps policy are profile-level. "Advanced" exposes the existing raw hub (groups /
sub-rules / providers / raw rules / raw YAML), off by default.

## II.13 UI/UX design

The constructor must be indistinguishable from the existing routing screens — same squircle
cards, color-coded chips, section headers, toasts — just speaking human and never showing a rule
string. This section pins it to FlClash's real Flutter design language. (The workspace's web-UI
skills — hallmark / impeccable / modern-web-guidance — do NOT apply; FlClash is Flutter /
Material 3. The references are the app's own component library + Material 3.)

**Design language to inherit (non-negotiable):**
- Pure **Material 3, fully ColorScheme-role-driven**. Never a literal `Color()`; every color is a
  `context.colorScheme.X` role or a centralized semantic token, so the constructor inherits
  dynamic color, the user accent, and pure-black OLED mode for free.
- **Semantic + opacity tokens** from `common/color.dart`: the `success`/`warning` extensions,
  `delayColor` / `quotaColor`, and the `opacityNN` alpha tokens. Reuse; never re-threshold.
- The **squircle shape** — `RoundedSuperellipseBorder` at the app radii (cards 14-16, chips 11,
  inputs 12, grouped lists 18/24). Plain `RoundedRectangle` reads as foreign.
- **Spacing** via the 16px base and the text-scale-aware `.ap` / `.mAp` multipliers + the
  canonical inset constants, so text scale 0.8-1.4 stays correct.
- **Typography** via stock M3 `TextTheme` roles (uppercase `labelMedium w800` section headers,
  `titleSmall` titles, `bodySmall onSurfaceVariant` secondary, tabular `labelMedium` numerics).
- **The mono rule:** `JetBrainsMono` means "raw mihomo/YAML" in this app. Never use it on a
  plain-language label; reserve it only for echoing a literal the user typed (a domain / IP / SSID).

**One route-color vocabulary (used everywhere):** reuse the existing `TargetChipKind` mapping so a
destination badge looks identical app-wide — Via VPN / server group = `primary` (hub icon); Block =
`error` (block icon); Direct / neutral = `onSurfaceVariant` (arrow icon); a Scenario / alt-route =
`tertiary` (alt_route icon). Render each as `CommonChip(type: tonal, tonalColor, avatar: Icon)`.

**Per-screen composition (all on existing components):**
- Every screen = `CommonScaffold` (title, icon-only app-bar actions, an extended
  `CommonFloatingActionButton` "Add" that auto-collapses on scroll); content structured with
  `ListHeader` sections and `CommonCard(filled)` cards.
- **Top-level entry** = a `RoutingHubView`-style list of chevron rows (Lists / Scenarios / Apps /
  Server / Advanced), pushed via `BaseNavigator.push` (300ms SharedAxis).
- **Lists:** add-FAB; each List a `ListItem` (kind icon + name + localized count subtitle +
  chevron). Adding opens an intent sheet ("Browse catalog" / "Paste domains" / "By country" / "By
  link"), then the List editor. Empty = `NullStatus` with a new themed illustration + an action CTA.
- **Catalog browser:** a sectioned `ListView` of selectable `CommonCard`s grouped by category
  (`ListHeader` per category), each card = icon + human name + one-line description + a tonal count
  chip; inline search `CommonTextField`. Multi-add via the `_MemberPickerSheet` checkbox pattern
  (Confirm disabled until >=1). Loading = centered spinner; fetch failure = `NullStatus` + retry.
- **Scenarios:** modeled on `rule_card.dart` + `edit_rule_dialog.dart`. Each rule a plain human row
  — "When [List] -> send [Via VPN / Direct / Block]" — left = a List/condition picker, right = the
  color-coded destination chip opening the target sheet. `ReorderableListView` for priority + a
  one-line "checked top to bottom" caption + a `_CollapsedFooter` "everything else -> default" card.
  AND/OR/NOT hidden behind an optional Advanced expander, never default.
- **Apps:** keep `AppRoutingView` essentially as-is (best-in-class: in-tunnel/bypass sections, app
  rows with icon + target chip, inline search, settings sheet); re-skin only the step-2 vocabulary
  to plain language, using the two-step `AppRoutingPickerSheet`.
- **Server picker:** a near-copy of `NodeSelectorSheet` (latency badge + check + secondaryContainer
  highlight), names via `EmojiText`; a fuller browser can reuse the proxies card-grid + delay-test
  FAB.

**Interaction surfaces (by depth):** full-page push for drill-downs; `showSheet` /
`AdaptiveSheetScaffold` (drag handle, full width) for pickers and multi-step editors — never a
`CommonDialog` for a multi-field editor (its 300px cap is exactly why `edit_rule_dialog` is a
sheet); `showCommonDialog` / `InputDialog` only for naming and yes/no.

**States (the honest contract):**
- Loading: the `_loading` gate -> centered `CircularProgressIndicator`.
- Empty: always `NullStatus` (never bare `Text`) with a themed StarBorder illustration + an action
  CTA; ship new List / Scenario / Catalog illustrations in the family.
- Success / honest-fail: standardize on `context.showNotifier` (top-right queued dismissible toast).
  Keep the universal write contract: every mutation returns `String? error`; non-null -> toast +
  revert the optimistic state. Persistent preconditions ("VPN is off, routing won't apply") use an
  inline `MaterialBanner`, mirroring the `findProcessOff` banner.

**Motion:** reuse `constant.dart` durations (100 / 200 / 300ms) and existing transitions (SharedAxis
push, FadeScale dialogs, FadeThrough value swaps, the spring segmented thumb, FAB extend/collapse).
Introduce no new transitions.

**Localization / a11y:** localize every new string into all four arb files (en / ru / zh_CN / ja)
with parameterized count strings (mirror `subRuleRuleCount` / `nullTip`). Use `EdgeInsetsDirectional`
(RTL machinery exists but is unshipped). Improve on the app's thin a11y: add `Tooltip` / `Semantics`
labels to icon-only controls and selectable cards.

## II.14 Rework vs new

- **Rework (re-skin / hide / unify):** collapse the 5-noun hub into the human Lists / Scenarios /
  Apps screens; re-skin the per-app step-2 picker into plain intents + a scenario chooser;
  re-skin `providers.dart` as the Lists screen and `sub_rules.dart` + the rules editor as the
  Scenarios screen; remove the Override overlay + global Added rules from the ordinary path; fence
  raw editors and raw YAML behind one off-by-default "Advanced" gate; relabel whitelist/blacklist
  as the plain "block unlisted apps" choice.
- **New (the thin layer):** the bidirectional model<->YAML bridge (the only substantial new
  logic); the Catalog library (curated human-named sets + country data + localization); the four
  List-source ingestion flows with auto-detect; the seed Lists/Scenarios + a small preset
  library; the no-magic pickers (Catalog browser, country picker, app picker, server picker); the
  universal materializer behind both paste-and-go and edit (II.9).
- **Design system (reuse, not invent):** every screen is built from the existing components +
  tokens catalogued in II.13 (CommonScaffold / CommonCard / CommonChip / NullStatus /
  AdaptiveSheetScaffold / showNotifier + the route-color vocabulary); the genuinely new UI work is
  the themed empty-state illustrations (List / Scenario / Catalog) and the all-new strings
  localized into 4 locales.
- **Out of v1 (decided):** a manual node editor. The pasted node stays read-only and
  runtime-selectable; editing/adding a server by hand is deferred (pure Dart `proxies:` editing
  when added, still no native code).

## II.15 Staged plan

- **Stage 1 — Domain model + bidirectional bridge (pure Dart, TDD, no UI).** New
  `lib/services/routing_model.dart` (Lists / Destinations / Rules / Scenarios / App-assignments)
  and a bridge that READS an arbitrary profile into the model (recognize-don't-rebuild,
  marker-naming, unrecognized -> Custom) and WRITES it back through the existing `with*()`
  losslessly. Tests assert: round-trip on the reference profile preserves it byte-for-byte; every
  written shape passes `validateConfigWithData`; re-apply is idempotent. This model + bridge is the
  single mechanism behind BOTH from-zero (Part I) and edit (II.9); the Part I synthesizer is
  refactored to seed the model and write through it, with no separate assembly path.
- **Stage 2 — Catalog + country data.** New `lib/services/routing_catalog.dart`: curated
  human-named -> public-set map (MetaCubeX subset + blocklists), GEOIP country table, icons,
  localized labels (EN/RU/JA/ZH). Pure data + lookups, unit-tested. Seed Lists + a "Smart split"
  Scenario as starting content.
- **Stage 3 — Lists screen.** Re-skin `providers.dart`: browse Catalog / add by URL (auto-detect
  behavior/format) / paste domains / pick a country; human name + icon; disambiguate a
  server-subscription URL from a rule-list URL by section + detection. No mihomo terms on screen.
- **Stage 4 — Scenarios screen.** Re-skin `sub_rules.dart` + the rules editor: an ordered list of
  "[List] -> [Direct/Via VPN/Block]" rows + a default; add a row by picking a List + a
  Destination; the app owns precedence. Seed "Smart split" is an editable example.
- **Stage 5 — Apps screen.** Re-skin the Apps tab: per-app intent chip (Through VPN / a scenario /
  Bypass / Block) sourced from existing scenarios; the "Block ads" toggle; the "Unlisted apps:
  allow / block" segment; the inline Server picker. New l10n; remove leakage strings.
- **Stage 6 — Seeds, presets, prefill + Advanced gate.** Preset scenarios ("RU smart split",
  "VPN only", "Direct + smart split") applied at onboarding (a pasted link yields a prefilled
  profile) and one-tap on any profile; move Override + global Added rules + the raw hub behind the
  Advanced gate (off by default); merge engine (`task.dart`) + drift storage untouched.
- **Stage 7 — Verify.** Unit (bridge round-trip on the reference profile, catalog lookups,
  per-source ingestion), widget tests (each picker writes the right model edit), an on-device gate
  (paste -> build a List + Scenario + assign an app -> confirm domestic-direct + blocked-via-VPN +
  ads-blocked + unlisted-no-internet, then tear down the emulator + Gradle daemon per the BUILD
  teardown rule), and the full gate set (dart format, analyze --fatal-infos, DCM unused, detekt,
  full test suite).

All UI stages (3-6) build strictly on the components and tokens catalogued in II.13 (UI/UX),
never bespoke widgets.

Touched: new `routing_model.dart` / `routing_catalog.dart` + tests; re-skin `providers.dart`,
`sub_rules.dart`, the rules editor, `app_routing.dart` (+ controller), `routing_hub.dart`,
`edit.dart`, `profiles.dart`, l10n, the Part I quickstart synthesizer. Backend (`yaml_rules_io`,
codecs, `aclFromTunYaml`, native) unchanged.

## II.16 Risks / open points

- **Reverse-mapping fidelity:** the bridge must distinguish app-generated artifacts from
  hand-authored YAML so a power user's manual rules are never misread as a preset and clobbered.
  Marker-naming + treating unrecognized shapes as "Custom / Advanced" is the guard; the
  round-trip test on the reference profile is the gate.
- **URL ingestion ambiguity:** a pasted URL may be a server-subscription (`proxy-providers`) or a
  rule-list (`rule-providers`). Resolved by section (Servers vs Lists) + content auto-detection;
  never ask the user to choose a mihomo container.
- **List behavior/format auto-detect:** sniff `mrs`/`text`/`yaml` and domain-vs-ipcidr on fetch;
  a single human fallback question ("domains or IP addresses?"), never the raw tokens.
- **First-match ordering:** generated/edited rules must keep correct precedence (ads REJECT before
  domestic DIRECT before region-blocked VPN before the default); the compiler owns ordering, the
  user never reorders raw.
- **Catalog drift + localization:** public set URLs/names can move and must be localized; the
  Catalog is versioned in-app, refreshed only after a tunnel exists, never fetched on the blocked
  cold path.
- **GEOIP on from-zero IR/CN:** the "by country" List kind needs geoip data; default it off for
  from-zero non-RU envelopes to avoid a geo-DB fetch on a blocked network (consistent with Part I).
- **Subscription refresh:** model edits must survive `Profile.update()` so a sub refresh does not
  drop generated Lists/Scenarios (the Part I reapply path is the hook).
- **Unified-mechanism drift:** the Part I synthesizer must be refactored ONTO the shared model +
  writer (II.9), not kept as a parallel path; a test that a from-zero seed and an equivalent edit
  produce the same shapes is the guard.
- **UX content cost:** new themed StarBorder illustrations (List / Scenario / Catalog) and
  essentially all-new strings localized into 4 locales are real content work, not just code.

## II.17 Links / external grounding

- MetaCubeX `meta-rules-dat` (geosite/geoip `.mrs` sets) — the Catalog's backing data.
- `runetfreedom/russia-blocked-geosite` — the RKN blocklist (a "by URL" List in the reference).
- Official mihomo wiki — proxy-providers content formats, rule-providers `behavior`/`format`,
  `sub-rules`, per-app `PROCESS-NAME` routing.
- Reference profile doctrine (whitelist + browser smart-split + ad-block + fail-closed) — from a
  real in-use mihomo mobile config; only public rule sets are named here, no private endpoints.

## II.18 Provenance

Part II is grounded in (1) a 7-reader multi-agent map (2026-06-29) of every profile-settings
editor in the recovered branch — app-routing, proxy-groups, the rules editor, sub-rules +
providers, the Override overlay, the hub / navigation / raw-YAML escape hatches, and the
persistence/apply backbone, each returning a capability map (edited YAML keys, current UX,
YAML-leakage points, strengths, redesign gaps, zero-YAML reuse verdict); and (2) a full read of a
real in-use power-user mobile profile, which validated the object model and forced the four
List-kinds, the URL-ambiguity split, and the Server-topology boundary; and (3) a 2-reader
design-system + UX map (2026-06-29) of FlClash's Material 3 tokens, reusable widget library, and
interaction / state / motion conventions, which grounds the UI/UX section (II.13). The reference RU
profile doctrine was taken from that config; only public rule sets are named.
