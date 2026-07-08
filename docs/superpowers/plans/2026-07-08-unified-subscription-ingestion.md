# Unified Subscription Ingestion — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development to implement task-by-task. TDD per task (write failing test, watch fail, minimal code, green, commit). Steps use `- [ ]`.

**Goal:** One ingestion pipeline for both entry points (create-profile and routing add-server), handling every common link/subscription format uniformly, with all Happ behaviour isolated behind one removable module and the per-subscription toggle gone.

**Architecture:** Five stages — resolve-wrapper → fetch → detect → convert → materialize. Detection is try-parse (attempt parsers in order), not heuristic. The core owns detect/convert/materialize; the Happ module registers a stage-0 Resolver and a stage-1 dual-fetch FetchStrategy into two registries and touches nothing else. Every subscription is materialized in-app to a `type: file` sidecar; mihomo never fetches subscriptions.

**Tech Stack:** Dart/Flutter, freezed, Intl (hand-edited l10n), dio (existing `request` channel). No new deps.

## Global Constraints

- English-only: source, comments, commit messages, PR. Rewrite any inherited RU/CN on touch.
- No em-dash anywhere in source/commits/PR. Use `,` `:` `.`.
- No AI co-author trailer on this fork.
- Comments: default none; if kept, <=3 lines, non-obvious *why* only.
- Build ONLY via `dart setup.dart android`; keystore-trap -> `.dev` flavor (`com.follow.clash.dev`); never overwrite prod `com.follow.clash`. Core pin stays libmihomo v0.3.0 / bridgeABI 3.
- Local gates before any push: `dart format`, `flutter analyze --fatal-infos`, DCM `check-unused-{code,files,l10n}`, `flutter test`, locale-parity, detekt (only if Kotlin touched — it is not here).
- l10n: hand-edit `lib/l10n/l10n.dart` + `lib/l10n/intl/messages_{en,ru,ja,zh_CN}.dart`. All 4 locales or locale-parity CI fails.
- TDD: pure `lib/ingest/**` logic is fully unit-testable with no device. Device only for the final emulator matrix.

---

## File Structure

**New — `lib/ingest/` (core):**
- `normalize.dart` — `Normalized` record + `Normalized normalize(String text)`. The single try-parse detector+converter. Absorbs `classifyArtifact` detection and the four `ArtifactKind -> proxies` switches.
- `xray.dart` — one `_iterXray(text, XrayNaming)` skeleton (flat / per-remark-label / slug); `convertOutbound` shared mapper (moved verbatim from `xray_json.dart`); `parseXrayObject` (v2rayN single-config object); `injectRemarkGroups` (moved). Re-exported names keep callers compiling.
- `sip008.dart` — `List<Map<String,dynamic>>? parseSip008(Object json)` (`servers[]` + `method`).
- `singbox.dart` — `List<Map<String,dynamic>>? parseSingbox(Object json)` (`outbounds[]` field-mapped to clash proxies).
- `synthesize.dart` — `Map<String,dynamic> synthesize(Normalized n)` (flat = the one-bucket case); `urlTestGroup(...)` helper (replaces the x4 literal).
- `registry.dart` — `Resolver` + `FetchStrategy` abstractions, mutable registries with `register`/`reset`, and the core default single-honest-GET fetch strategy.
- `pipeline.dart` — `Future<Ingested> ingest({String? url, String? inlineText, Map<String,String>? extraHeaders})`: resolve -> fetch -> normalize. Plus `synthesizeProfileBytes(Ingested)` (create-profile) and `materializeProvider(...)` (routing) adapters.

**New — `lib/ingest/happ/` (removable module):**
- `happ_identity.dart` — `happUserAgent`, `happHwidHeader`, `happHeaders`, hwid gen (moved from `common/happ.dart`).
- `happ_module.dart` — `registerHappModule()` / `unregisterHappModule()`. Registers the Happ Resolver (guarded `/happ -> /api/sub`, `happ://add/<url>`, follow 3xx) and the dual-fetch FetchStrategy (honest + Happ-identity in parallel, keep richer, tie -> honest).

**Modified:**
- `services/quickstart_config_service.dart` — drop `ArtifactKind`/`classifyArtifact`/`synthesizeConfig`/`synthesizeGroupedConfig`/`artifactToConfigBytes`; keep `deriveSubscriptionName`/`normalizeSubKey`/`applyQuickStartRouting`.
- `common/xray_json.dart` — deleted; contents split into `ingest/xray.dart`.
- `common/happ.dart` — deleted; moved to `ingest/happ/happ_identity.dart`.
- `models/profile.dart` — `update()` -> pipeline; remove `happMode` field (freezed regen), `_looksUnusable`, `_maybeConvertSubscriptionBody`, `fetchWithHappFallback`.
- `views/profiles/routing_constructor.dart` — `_addServer`/`_addSubscription`/`_probeSubscription` collapse onto pipeline; `_editSubscription` uses plain URL dialog.
- `controllers/setup_controller.dart` — `_prefetchXrayProviders` -> `_materializeSubscriptions` (all http subs, not just xray-marked).
- `services/routing_model.dart` — drop `happ` from `updateSubscription`; simplify `SubscriptionSource.xray` to a materialize/grouping marker only; `_subToProvider` de-Happ-coupled.
- `controllers/profiles_controller.dart`, `views/profiles/add.dart` — drop `happMode` params; use pipeline.
- `widgets/input.dart` — `HappUrlDialog` -> `UrlDialog` (no switch).
- l10n — remove `happMode`/`happModeDesc` (4 locales); add keys only if a new string is introduced.

**New tests:** `test/ingest/{normalize,xray,synthesize,sip008,singbox,registry,happ_resolver,happ_fetch}_test.dart`.

---

## Phase 1 — Pure core: normalizer + collapses (no device)

### Task 1: Unified xray iterator + convertOutbound move
**Files:** Create `lib/ingest/xray.dart`; Test `test/ingest/xray_test.dart`; later delete `lib/common/xray_json.dart`.
**Produces:** `convertOutbound`, `iterXray(text,{XrayNaming naming,...})`, `parseXrayObject`, `XrayGroup`, `RemarkGroup`, `SluggedXray`, `injectRemarkGroups`.
- [ ] Test: same xray array yields identical proxies via flat vs grouped naming (the latent-bug fix); slug naming produces `<key>-rNN-MM`; reality-no-key dropped.
- [ ] Move `_convertOutbound`+helpers verbatim as `convertOutbound`; implement one `iterXray` skeleton the three old fns delegate to; green; commit.

### Task 2: SIP008 + sing-box parsers
**Files:** Create `lib/ingest/sip008.dart`, `lib/ingest/singbox.dart`; Test `test/ingest/{sip008,singbox}_test.dart`.
**Produces:** `parseSip008(Object)`, `parseSingbox(Object)`.
- [ ] Test each against a known-good literal (independent source, not recomputed): SIP008 `servers[]`+`method` -> ss proxies; sing-box `outbounds[]` vless/ss -> clash proxies; malformed -> null.
- [ ] Implement field-maps; green; commit.

### Task 3: The normalizer
**Files:** Create `lib/ingest/normalize.dart`; Test `test/ingest/normalize_test.dart`.
**Consumes:** Task 1/2 parsers, `share_link.dart` (`parseShareLink`, `parseSubscriptionContent`, `shareLinkSchemes`, `decodeBase64Text`).
**Produces:** `Normalized ({List<Map> proxies, List<XrayGroup>? groups, int skipped, SubMeta? meta})`; `Normalized normalize(String text)`; `ClashPassthrough`/`SubUrl` sentinels for the non-pure boundary.
- [ ] Test try-parse order: scheme -> share; JSON -> xray-array(grouped) / xray-object / SIP008 / sing-box (disambiguation by keys); YAML `proxies:` -> clash-passthrough; base64 -> recurse; unknown -> empty. Assert through the returned record.
- [ ] Implement; green; commit.

### Task 4: synthesize() unification
**Files:** Create `lib/ingest/synthesize.dart`; Test `test/ingest/synthesize_test.dart`.
**Consumes:** `Normalized`, `applyQuickStartRouting`.
**Produces:** `synthesize(Normalized)`, `urlTestGroup(...)`.
- [ ] Test: flat -> single PROXY url-test; grouped -> PROXY select over per-remark url-test groups; unique-name collisions handled.
- [ ] Fold `synthesizeConfig`+`synthesizeGroupedConfig` into one; green; commit.

### Task 5: Rewire create-profile onto pure core (no Happ yet)
**Files:** Modify `services/quickstart_config_service.dart`, `controllers/profiles_controller.dart`, `views/profiles/add.dart` (guard only), `models/profile.dart` (`_maybeConvertSubscriptionBody` -> `synthesize(normalize(...))`).
- [ ] Replace `classifyArtifact==unknown` guards with `normalize(text).proxies.isEmpty && !isClashOrUrl(text)`; `artifactToConfigBytes` becomes `synthesize(normalize())`; keep clash/subUrl boundary.
- [ ] Full `flutter test` green (existing + new); `flutter analyze`; commit. **Deliverable: flat-vs-grouped bug fixed, SIP008/sing-box gained, both create-profile still works. No behaviour change for Happ yet.**

## Phase 2 — Registries + Happ module (fixes cloVPN)

### Task 6: Resolver + FetchStrategy registries
**Files:** Create `lib/ingest/registry.dart`; Test `test/ingest/registry_test.dart`.
**Produces:** `abstract Resolver { Future<Resolved?> resolve(String input) }`, `abstract FetchStrategy`, `registerResolver/registerFetchStrategy/resetIngestRegistry`, core default fetch (single honest GET via `request`).
- [ ] Test: empty registry passes input through unchanged and fetches once honestly; a fake resolver rewrites; reset clears.
- [ ] Implement; green; commit.

### Task 7: Happ resolver (the cloVPN fix)
**Files:** Create `lib/ingest/happ/happ_identity.dart` (move from `common/happ.dart`), `lib/ingest/happ/happ_module.dart`; Test `test/ingest/happ_resolver_test.dart`.
**Produces:** `registerHappModule()`, Happ `Resolver`.
- [ ] Test: `https://h/happ?token=X` -> `https://h/api/sub?token=X`; `happ://add/https://h/s` -> `https://h/s`; no-false-rewrite on `https://h/sub/happ-x?token=X` (path not exactly `/happ`); missing token -> passthrough.
- [ ] Implement guarded rewrite (exact `/happ` path + `token`/`id` query); green; commit.

### Task 8: Happ dual-fetch strategy
**Files:** Modify `lib/ingest/happ/happ_module.dart`; Test `test/ingest/happ_fetch_test.dart`.
**Produces:** Happ `FetchStrategy` (register alongside resolver).
- [ ] Test with injected fake fetchers: honest+Happ run, richer (more proxies after normalize) wins; equal count -> honest; one side errors -> other used.
- [ ] Implement (parallel fetch, normalize both, compare); register both in `registerHappModule`; green; commit.

### Task 9: Wire module on at startup; pipeline uses registries
**Files:** Create `lib/ingest/pipeline.dart`; Modify app init (call `registerHappModule()` once); Test extends `registry_test`.
**Produces:** `ingest(...)` orchestrator used by both entry points.
- [ ] Test: with module registered, a fake `/happ` fetch that returns HTML at `/happ` and xray-array at `/api/sub` yields 5 groups / 11 nodes; with module unregistered, `/happ` normalizes empty (fails cleanly).
- [ ] Implement pipeline resolve->fetch->normalize; green; commit. **Deliverable: cloVPN link resolves to the real subscription through the pure pipeline.**

## Phase 3 — Unify entry points

### Task 10: Routing add-server onto pipeline
**Files:** Modify `views/profiles/routing_constructor.dart` (`_addServer`, `_addSubscription`, `_probeSubscription`).
- [ ] `_addServer` collapses to: `ingest(inlineText/url)` -> if single-fetchable-sub store `SubscriptionSource`, else `_addNodes(normalized.proxies)`. Grouped xray uses the SAME grouped path as create-profile (drop flat `parseXrayJson` here).
- [ ] Manual-parity check via existing routing tests; `flutter test`; commit.

### Task 11: Profile.update onto pipeline
**Files:** Modify `models/profile.dart`.
- [ ] `update()` -> `ingest(url:url)` (dual-fetch strategy handles the old Happ fallback); materialize; keep header/quota/reapply-routing/dangling logic.
- [ ] `flutter test`; commit. **Deliverable: one pipeline, both entry points, no format copy-paste.**

## Phase 4 — Remove toggle + materialize-all

### Task 12: Remove per-subscription Happ toggle
**Files:** Modify `widgets/input.dart` (`HappUrlDialog`->`UrlDialog`), `views/profiles/add.dart`, `views/profiles/routing_constructor.dart` (`_editSubscription`), `controllers/profiles_controller.dart`, `services/routing_model.dart` (`updateSubscription` drops `happ`), `models/profile.dart` (drop `happMode` field), l10n (remove `happMode`/`happModeDesc` x4).
- [ ] Replace dialog + drop all `happMode`/`happ:` params/fields; freezed regen (`dart run build_runner build`); update `messages_*` + `l10n.dart`.
- [ ] `flutter analyze --fatal-infos`; DCM unused; `flutter test`; commit.

### Task 13: Materialize-all subscriptions
**Files:** Modify `controllers/setup_controller.dart` (`_prefetchXrayProviders` -> `_materializeSubscriptions`), `services/routing_model.dart` (`_subToProvider`).
- [ ] Generalize the apply-time prefetch to fetch+normalize+write a `type:file` sidecar for EVERY http subscription (grouped keeps `injectRemarkGroups`; plain writes a flat `proxies:` file). Honour `profile-update-interval`; cache-failover unchanged.
- [ ] `flutter test`; commit. **Deliverable: mihomo never fetches subscriptions; module-off still works for non-Happ.**

## Phase 5 — Gates, build, emulator verify

### Task 14: Full gate sweep + build .dev
- [ ] `dart format .`; `flutter analyze --fatal-infos`; DCM `check-unused-{code,files,l10n}`; `flutter test`; locale-parity. Bump pubspec rc. Build `dart setup.dart android --arch arm64` (keystore-trap -> `.dev`).

### Task 15: Emulator 3-link matrix
- [ ] Install `.dev`, cold start. For each of clovpn (`/happ?token=`), gosapi (`m7.../sub/...`), blanc (`withblancvpn.online/s/...`): create-profile AND add-to-existing both yield real nodes/groups (clovpn = 5 groups / 11 nodes), connect verifies (204 honest gate), logcat shows no `convert v2ray subscribe error` / no single-`COMPATIBLE` fallback.
- [ ] Module-off spot check: a `/happ` link fails cleanly, a plain clash sub still works.
- [ ] Teardown: `adb emu kill` (unless user asked to keep), `./gradlew --stop`, `pkill` kotlin/gradle daemons, `pgrep` clean.

### Task 16: Docs + backlog
- [ ] Update `docs/` design status to done; move BACKLOG ingestion item to DONE; commit. PR only on explicit user approval (external gate).

---

## Verification (independent oracle)
- Unit tests take expected values from known-good literals / worked examples, never recomputed the way the code computes them.
- Emulator = the external oracle for the 3 real links; logcat greps for the concrete failure signatures, not just success.

## Risks / rollback
- **Materialize-all** moves fetching from mihomo to the app for previously-live routing providers. Mitigate: reuse existing apply-time prefetch seam (no new timer), honour update-interval, keep cache-failover. Rollback: revert Task 13 alone (Tasks 1-12 stand independently).
- **`/happ -> /api/sub`** assumes the standard same-origin template; exact-path + token/id guard makes anything else pass through untouched.
- **Dual-fetch** doubles sub fetches while module on; acceptable (small, infrequent).
- Each phase is independently revertable; the cloVPN fix lands at Phase 2, before the riskier Phase 4.
