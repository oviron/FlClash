# Unified subscription and link ingestion

Status: implemented on `feat/unified-ingestion` (rc30), verified on the emulator
against three real links (cloVPN /happ, gosapi, blanc) through both entry points
and into a production clash profile. English-only per fork policy.

## Problem

Two parallel ingestion paths duplicate format handling:

- create-profile: `addProfileFormURL` -> `Profile.update` -> `_maybeConvertSubscriptionBody` -> `classifyArtifact` + `artifactToConfigBytes`.
- add-to-existing (routing constructor): `_addServer` -> its own `classifyArtifact` switch -> `_addNodes` / `_addSubscription`.

Consequences found in the code and verified on device:

- The `ArtifactKind -> proxies` mapping is copy-pasted across four sites (the two switches above, the apply-time xray prefetch, and caller special-cases for `subscriptionUrl`/`clashYaml`). A new format means editing all of them.
- xray-JSON is converted two different ways: grouped (`parseXrayJsonGroups`) on the profile path, flat (`parseXrayJson`) on the editor path. Same input, different result: a latent bug.
- Three near-duplicate iterators walk the same xray array (`parseXrayJson`, `parseXrayJsonGroups`, `slugXrayGroups`); the url-test group literal is copied four times.
- Format handling is coupled to the per-subscription "Happ mode" UA toggle (`byRemark = happ && classifyArtifact == xrayJson`), spread across probe/model/serialize/prefetch.

Root cause of the cloVPN failure (both entry points, both toggle states, verified
on the emulator): the `links.clovpn.org/happ?token=...` link is an HTML launcher
page, not a subscription. The app fetches and tries to parse it as a config
(create-profile -> `yaml: line 25: mapping values...`; add-server -> a single
`COMPATIBLE` node from a live provider mihomo cannot parse). The real subscription
is `.../api/sub?token=...` (xray-JSON, 5 groups / 11 nodes). The toggle only adds a
Happ UA to the probe fetch, but `/happ` returns HTML for any UA, so `byRemark`
never becomes true and the raw `/happ` URL is stored with no materialization.

## Goal

One ingestion pipeline shared by both entry points. Handle every common
link/subscription format uniformly. Isolate all Happ-specific behaviour behind one
removable module. Remove the per-subscription toggle. No copy-paste.

## Industry basis (from competitor research)

mihomo, NekoBox, v2rayN, v2rayNG and Hiddify all use ONE normalizer that both
entry points call; they differ only by a preceding fetch and a following store.
Detection is try-parse (attempt each parser in order), not heuristic sniffing.
base64 is a decode layer, not a format. Wrapper/launcher links are a pre-stage
resolved before the format sniffer. Subscription metadata (userinfo, title, hwid)
is read from headers in parallel with body detection.

## Design: one pipeline, five stages

Both entry points run the same pipeline; they diverge only at stage 0/1 (whether a
fetch runs first) and stage 4 (how the result is stored).

| Stage | Owner | Behaviour |
|---|---|---|
| 0. Resolve-wrapper | Happ module | Launcher/redirect -> concrete sub URL or inline body. Runs before anything else. |
| 1. Fetch | core + Happ module | GET (proxy then direct fallback); read `subscription-userinfo`/`profile-title`. Happ module adds dual-fetch. |
| 2. Detect | core | try-parse, cheap/structural first (see order below). |
| 3. Convert | core | `-> Normalized { proxies, groups?, skipped, meta }`. The single conversion seam. |
| 4. Materialize | core | app writes a local provider/profile file; mihomo reads it. Diverge: profile-synth vs routing-inject. |

### The single normalizer

`normalize(text) -> Normalized { proxies, groups?, skipped, meta }`, try-parse order:

1. starts with a known `scheme://` -> single share link or share-link list;
2. JSON parses -> disambiguate by keys: xray-JSON array (Happ), xray-JSON object (v2rayN), SIP008 (`servers[]`+`method`), sing-box (`outbounds`);
3. YAML with `proxies:` / full-config keys -> clash;
4. else base64-decode and recurse (fall back to plaintext on decode failure);
5. share-link list: split, dispatch each by scheme through a per-scheme registry, unknown scheme = skip (not fatal).

`artifactToConfigBytes` (create-profile) becomes `synthesize(normalize(...))`;
`_addServer` (editor) becomes `inject(normalize(...))`. `subscriptionUrl` and a
raw clash doc stay outside the pure normalizer as the fetch/passthrough boundary.

### Happ module (removable)

One folder (`lib/ingest/happ/`). Registers into two registries and nothing else
in the core references Happ:

- Resolver (stage 0): `.../happ?token=|id=` -> same-origin `.../api/sub?...`; `happ://add/<url>` -> `<url>`; follow HTTP 3xx. Guard: rewrite only when the path is exactly `/happ` and a `token`/`id` query exists; otherwise pass through untouched. Scope: web-launcher only (encrypted `happ://crypt*` is out of scope).
- FetchStrategy (stage 1): dual-fetch. Fetch honest and fetch with Happ identity (`User-Agent: Happ/3.6.0` + `x-hwid`) in parallel, normalize both, keep the result with more proxies (tie -> honest, to minimize identity exposure).

Module disabled/removed: drop the two registrations. The core then resolves only
non-Happ inputs and fetches with a single honest request; every non-Happ format
still works. There is no per-subscription UI toggle; the module's on/off is the
only control.

### Materialization

The app owns all subscription fetching, because dual-fetch and Happ identity are
impossible for a live mihomo provider (it does one honest GET and cannot spoof).
Every subscription is fetched, normalized, and written to a local provider sidecar
that mihomo loads as `type: file`. Native formats (clash / base64 / share-link
lists) are materialized too, for uniformity and so the app owns caching, dedup,
naming, and update scheduling. Refresh is an app timer re-running the pipeline,
honouring the panel's `profile-update-interval`.

## What collapses (DRY)

- Four conversion sites -> one `normalize`.
- Three xray iterators -> one `_iterXray(text, naming)` skeleton (naming = flat / per-remark label / slug); `_convertOutbound` stays the shared mapper.
- `synthesizeConfig` + `synthesizeGroupedConfig` -> one `synthesize` (flat = the one-bucket case).
- url-test group literal (x4) -> one `urlTestGroup(...)` helper.
- The flat-vs-grouped xray divergence disappears (one converter).

## Gained for free

SIP008 and sing-box JSON (field-mapped to clash proxies in-app, like xray-JSON).

## Out of scope

- Encrypted `happ://crypt2|3|4` deep links (RSA envelope, needs Happ's embedded keys, brittle across Happ versions).
- Lossless pass-through of xray-JSON to a core: we run mihomo, not xray, so the lossy field-map (`_convertOutbound`) stays the only option, same as today.

## Risks

- Materialize-all moves fetching from mihomo to the app for previously-live providers. Mitigate: keep the current auto-update cadence and honour the update-interval header.
- The `/happ -> /api/sub` rewrite assumes the standard same-origin Happ page template. Mitigated by the exact-path + token/id guard; anything else passes through.
- Dual-fetch doubles subscription fetches while the module is on. Acceptable (bodies are small and infrequent). Optional later: cache a per-sub "Happ yields more" verdict and stop dual-fetching where it does not.

## Verification

- Unit: `normalize` per format (clash / base64 / share-link / xray-object / xray-array / SIP008 / sing-box), including the flat-vs-grouped fix; the Happ resolver (`/happ->/api/sub`, `happ://add`, redirect, and no-false-rewrite on a normal `.../sub/happ-x?token=`); dual-fetch prefers the richer result.
- Emulator: the cloVPN `/happ` link through both entry points yields 5 groups / 11 nodes; a plain clash subscription still works; with the module disabled, non-Happ formats still work and a `/happ` link fails cleanly.
