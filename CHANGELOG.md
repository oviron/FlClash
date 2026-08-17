## v0.16.0

- Onboarding, paste-and-go: a first-run "Paste your key" on-ramp accepts a share link (`vless`/`vmess`/`ss`/`trojan`/`hysteria2`/`tuic`), a base64 subscription blob, a subscription URL, or a QR, and builds a leak-hardened full-tunnel profile underneath. "Connected" is asserted only after a functional HTTP-204 probe succeeds through the tunnel, never on handshake alone

- Routing constructor: a plain-language per-profile editor (Lists, Scenarios, Apps, exit) sitting on a lossless YAML round-trip that preserves every unmodeled key and comment. The raw proxy-group / rule / sub-rule / provider / DNS editors move under Advanced. Deleting a proxy, group, or list is now referentially consistent: containment references are cascaded (and emptied groups pruned), while a proxy or group still named by a rule or used as another node's `dialer-proxy` is refused with a message instead of leaving a dangling reference

- Per-profile app routing is now a three-way choice, All / Selected / Except, mapped to `tun.include-package` / `tun.exclude-package` and applied at `VpnService.Builder`. All means literally all apps (any stale global filter is force-disabled), so a whitelist/blacklist profile can keep bank and government apps out of the tunnel with an OS-level guarantee. Changing the set on the active profile re-establishes the tunnel automatically instead of waiting for an app restart

- Configurable tunnel MTU (default 1400). Backed by libmihomo-android bridgeABI 3, SHA-256 + GPG pinned

- Fixed a reproducible `:remote` core-process crash-loop (SIGABRT) on Android 11+ whenever process-based routing was active. mihomo's `resolveProcess` upcall received an empty `getPackagesForUid()` array (package-visibility filtering) and passed it through a `.first()` that threw across the JNI boundary, aborting the core the moment a rule matched on process. The core bump to bridgeABI 3 null-guards the native upcall, and `metadata.Uid` is revived over a `uid\npackage` return protocol so UID-based rules match again; the consumer replaces the throwing `.first()` with `firstOrNull`. Verified on Android 15 with `find-process-mode: strict` under multi-app traffic

- Backported a batch of fixes harvested from the fork ecosystem: auto-stop the tunnel when a profile parses to zero usable proxies; default `global-client-fingerprint: chrome` (uTLS ClientHello mimicry, one fewer DPI signal); a Quick Settings Tile cold-start race fix; a screen and Doze gated wake lock plus a foreground-gated notification poll to cut idle battery; a remote-URL sync button for override scripts; a collapse-all control and an always-on delay-test button in the proxies list; a GUI editor for the DNS `proxy-server-nameserver-policy` map; in-app log-level filtering; and assorted UX fixes (delay-test lock reset, synchronous system-back handling, delay-cache reset on restart and resume)

- Bundled a baseline GeoSite database with a background auto-update, so the first connect on a network that blocks GitHub no longer stalls on a geo-DB download; a raw geo-load error in the apply path is now suppressed

- Unified subscription and link ingestion: one pipeline now backs both entry points (create-profile and the routing constructor's add-server). A single try-parse normalizer handles share links and lists, base64, clash, xray-JSON (Happ, per-remark grouped), and now SIP008 and sing-box JSON, so a new format is added in one place. All Happ behaviour is isolated in one removable module (`lib/ingest/happ/`) that plugs a launcher resolver (`/happ?token` and `happ://add/` rewrite to the real subscription) and a dual-fetch strategy (honest + Happ identity, richer result wins) into the core; the per-subscription "Happ mode" toggle is gone. Every non-clash subscription is materialized in-app to a `type: file` provider the core can serve, with per-provider quota (used / total / expiry) surfaced in the Providers sheet

- Fixed group rename lowercasing the name. Creating or renaming a proxy group in the routing constructor no longer forces the name to lowercase or rewrites its punctuation. A group name is a verbatim, case-sensitive mihomo reference (the same string that rules, the exit, `use` and `members` point at), not a slug, so it is stored as typed and only de-duplicated on collision, matching how imported and subscription-backed groups (`Besaev-RU`, `GoVPN-auto`) already keep their case. The slug form stays where it is actually needed: filter-list ids, scenario keys, and auto-generated per-remark subscription groups

- The bundled core is libmihomo-android v0.3.3 (mihomo v1.19.30), up from v0.3.0 (mihomo v1.19.27) over three patch bumps. Picks up two `crypto/tls` CVEs (2026-42505 and 2026-56862), a fix for the TUN DNS-hijack path answering with zero-filled or stale packets when a reply outgrew the send buffer (a name resolving to 100+ A records), Tailscale recovering after the network comes back, and a batch of DNS correctness and traffic-sniffing fixes. bridgeABI is unchanged at 3, so the facade contract is the same; the `.aar` SHA-256 and GPG signature are re-pinned in `setup.dart`

- The proxy list now hydrates from a per-profile snapshot on cold start, so the Proxies screen renders the last known groups immediately instead of blinking the empty-state illustration until the core has loaded and answered. The snapshot is a disposable cache persisted after each group refresh and overwritten by the first live update; a decode failure is ignored

- The Quick Settings tile and the home screen can no longer disagree about whether the tunnel is up. The app carried two independent notions of "running": the tile read the service's real run time on every shade open, while the home button read a value written only by a one-second polling loop that started as a side effect of a successful profile apply. A failed apply (an unreachable subscription is enough) left that value null forever, and the resume handler restarted the loop only when it already said "running" — so the one state that needed repairing was the one preventing the repair. The service is now the single source of truth: it pushes every run-state change to the app, and cold start reads it back directly. Resume repairs the UI in one direction only, raising a stale "stopped" to "running" but never the reverse: a start in flight reports a run time of zero for a few milliseconds, and a two-way resync acted on that, tearing the tunnel's UI down mid-connect and churning the apply pipeline. Genuine stops arrive on the push, which cannot race a start. `:remote` also clears its run time when the tunnel dies, so the value the tile trusts stops reporting a tunnel that no longer exists, and `VpnService.onRevoke` now stops the service outright — disconnecting from the system VPN dialog, or letting another VPN app take over, is reflected in both places without restarting the app

- A profile apply no longer fetches subscriptions through the tunnel it is still building. Provider URLs were routed to the core's mixed port whenever the tunnel was up, so applying a profile while connected fetched the subscription that *defines* the proxies through those same not-yet-loaded proxies. The fetch failed, the provider was written out empty, and routing collapsed to REJECT. Fetches during an apply now go direct, which is what they did by accident before the run-state work made "connected" true earlier

- Log settings reach the core again. Levels and the log-file path are set once per core process, but the app only sent them at its own startup — before any core exists — so the file sink never opened and `debug.log` stayed empty. They are now re-applied whenever a core comes up, including after a restart

- Importing a QR code from an image works for every payload the app can already ingest. The gallery path had its own, narrower gate than the camera and the paste-a-link dialog: it accepted only an `http(s)` URL or a bare share link, so a base64 subscription blob or a pasted clash document was rejected outright. It also read the first decoded barcode without checking that anything decoded at all, turning an unreadable image into a `Bad state: No element` toast. Both paths now run the same ingestion check, an image holding several codes picks the first usable one, and the two failures are told apart: "no QR code found" versus "read it, but it is not a subscription, link or config"

- Settings → Application now offers to place the Quick Settings tile. The tile itself has always shipped, but Android never adds a third-party tile on its own — it has to be dragged in from the Quick Settings editor, which most people never find. On Android 13+ the entry raises the system's own one-tap prompt (`StatusBarManager.requestAddTileService`); on older releases it spells out where the editor is

- New Resource usage screen (Settings → Application) reporting what the app actually consumed — CPU time, wake-lock time and traffic — since the current connection, or since boot when the app was started into an already-running tunnel. The figures come from the system's own per-UID counters (`SystemHealthManager`), which cover the core process too, and the screen explains why Android's battery screen shows so little for a VPN: tunnelled traffic is billed to the app that originated it, and the tunnel wake lock is released as soon as the screen goes off

- Connections can now be sorted by traffic or speed. A sort control in the Connections app bar offers Default, Traffic (cumulative up plus down bytes) and Speed. Per-connection speed is not reported by the core, so it is derived as the byte delta between successive one-second snapshots; a new connection or a counter reset reads as zero

## v0.15.4

- Removed the ByeDPI integration entirely: dropped the `bydpi` product flavor and the embedded byedpi DPI-bypass core, along with its settings UI, strategy tester, host list, and the `libbyedpi-android` `.aar` dependency. The app collapses to a single variant (`com.follow.clash`, no suffix) and APK artifacts are now named `FlClash-<version>-android-<abi>.apk` (no `-classic`/`-bydpi`). mihomo remains the only bundled core

## v0.15.3

- Fixed a dead tunnel on devices that are missing an app listed in a profile's per-app allow/deny list. The list (from a profile's `tun.include-package` / `exclude-package`, or the GUI access control) was applied by calling `VpnService.Builder.addAllowedApplication` / `addDisallowedApplication` for each package, and Android throws `NameNotFoundException` for a package that is not installed. That unhandled exception aborted the entire tunnel build before `establish()`, so the VPN switched on but carried no traffic at all: an empty speed graph and nothing loading. It hit shared profiles hardest, since one profile listing apps that exist on one phone but not another (a ReVanced/microG build, Google Meet, or Chrome on a vendor ROM that ships its own browser) bricked the tunnel on whichever phone lacked any single one of them. Each package is now added independently; a missing one is skipped and logged ("VPN allow-list: skipping not-installed app <pkg>") instead of taking the tunnel down with it

## v0.15.2

- DNS robustness for censored networks, made the default instead of an opt-in. The `system://` fallback for `proxy-server-nameserver` (added in v0.15.1) is now injected unconditionally, not only when "Append system DNS" is enabled — the failure it prevents (a domain-named proxy server that can never resolve once the configured DoT/DoH is blocked, stranding the whole tunnel in an endless resolve-retry) is total, so it should never sit behind a toggle that defaults off

- Hardened the built-in DNS defaults against state DPI. `nameserver` now defaults to IP-literal DoH on censorship-surviving resolvers (Quad9 `9.9.9.9`, AdGuard `94.140.14.14`) instead of hostname DoH on Google/Cloudflare: a hostname endpoint needs a poisonable plain-`:53` bootstrap and leaks a cleartext SNI (`dns.google`/`cloudflare-dns.com`) that RU/CN middleboxes reset, and both providers are also IP-blocked in RU. `proxy-server-nameserver` defaults to `[system://, IP-literal DoH]` instead of DoT-only `:853`, a port dropped wholesale on many censored networks. These defaults apply only to imported configs that omit a `dns:` block; profiles that ship their own DNS are untouched

- `dns-hijack` now also captures TCP/53 (`tcp://any:53`), not only UDP, so a DNS query that falls back to TCP (e.g. after UDP `:53` is dropped) is still intercepted instead of leaking past the tunnel

## v0.15.1

- DNS: "Append system DNS" now also appends the system resolver (`system://`) to `proxy-server-nameserver`, not just `nameserver`. A proxy whose server is a domain (rather than a raw IP) could otherwise never be resolved when the user's configured DoT/DoH was blocked by the network (e.g. RU networks dropping :853), silently stranding the entire tunnel in an endless resolve-retry loop; the system resolver still answers for the proxy host, so the tunnel connects

## v0.15.0

- Network rules (auto VPN on/off by network) rewritten into a self-contained module. The observer and decision engine now run in a resident foreground service in the default process, so a network change (e.g. Wi-Fi to cellular with the screen off and the UI killed) is still acted on. Previously the logic lived in the UI process and silently stopped working once Android reclaimed it

- Added an explicit baseline: "When no rule matches" can leave the VPN unchanged (default), force it on, or force it off, so leaving a matched network no longer strands the VPN in whatever state it was last left in

- A manual VPN toggle now wins over the rules until the network actually changes, instead of being immediately reverted by the next network event

- Rule precedence is now by specificity (a named-Wi-Fi rule beats a generic "any Wi-Fi" rule regardless of list order); added Ethernet as a matchable network type; rules whose conditions a newer version wrote and this build cannot parse are shown as invalid instead of appearing active but dead

## v0.14.0

- In-app core version switching (Tools -> Engine -> Library version): list, download, and run any ABI-compatible libmihomo / libbyedpi release without reinstalling the APK. Each downloaded `.aar` is verified on device (SHA-256 + detached GPG signature against the pinned signing key) before its `.so` is extracted to app-internal storage

- Switching recycles the `:remote` process so the new core `.so` is loaded fresh; the VPN reconnects automatically on the new core. Incompatible releases (different bridge ABI) are shown as "requires app update". The APK-bundled core stays as the always-available default and fallback

- The Library version screen shows the bundled core version on the Active row and marks the matching available release as the current/bundled one, so it is clear at a glance whether a newer version exists

- ByeDPI in the version picker is gated by the build flavor: a non-byedpi build neither bundles, lists, downloads, nor installs the byedpi core

- Bundled ByeDPI strategy set expanded to 80: two upstream fake-packet strategies added (long TLS fake, QUIC fake). The remotely-updatable `strategies` release was refreshed to match

## v0.13.15

- Update bundled cores: libmihomo 0.1.3 → 0.1.4 (mihomo v1.19.25 → v1.19.26; a `no_tailscale` build drops the unused Tailscale stack, shrinking `libclash.so` from 46.7 MB to 35.4 MB in the APK), libbyedpi 0.1.0 → 0.1.1

- Both native libraries now ship a `metadata.json` release asset (bundled core version + bridge ABI + SHA-256) and carry the core version in the release title; pins are verified by SHA-256 + GPG signature

## v0.13.14

- Internal refactor (no behavior change): the monolithic `controller.dart` is split into a thin facade-dispatcher plus focused per-area controllers, and the ByeDPI / strategy-test and manager logic is moved onto testable seams; adds ~1175 lines of unit tests

## v0.13.13

- ByeDPI settings apply live, no manual restart: changing the strategy, port, mode, fallback, or applying a test result now reloads only what is affected (mihomo config and/or the byedpi engine) while the VPN is running. The "Restart ByeDPI" button stays as a manual escape hatch

- VPN settings that require rebuilding the tunnel (per-app app list, TUN stack, IPv6, system proxy) now re-establish automatically (debounced to batch edit bursts) instead of showing a "restart to apply" prompt

- Fix: per-app list editor. "Save" now clears the unsaved state, so the button hides and exiting no longer asks to save again; also fixes the profile-scoped editor where the unsaved state never cleared

- Fix: applying a strategy from the test now restarts byedpi with the new args (it kept the previous strategy until a manual restart), and exclude-only changes rebuild routing instead of being a no-op

## v0.13.12

- Strategy test is now a manager: re-test a single strategy, sort (%/name/date) and filter (all/tested/≥40%), remove a strategy, prune everything below 40%, or reset to the bundled set. The curated set persists and is what gets tested/applied

- Fix: strategy update fetches GitHub directly (the path FlClash's own traffic uses), so it works under default-REJECT (whitelist) routing where the proxy rejected the app's own request

## v0.13.11

- Test-driven host routing: applying a strategy from the test now routes only the hosts it verified through ByeDPI; hosts it can't pierce fall back to the VPN (no longer broken). Apply shows the ByeDPI/VPN split

- Strategy test is now a dashboard: per-strategy results + timestamps persist and render from cache; the active strategy is badged

- Fix: updating strategies through the VPN no longer fails with 407 (answers the local proxy's inbound-auth challenge)

## v0.13.10

- In-app ByeDPI strategy auto-test: a Strategy-test screen runs each strategy through a standalone byedpi SOCKS proxy and ranks them by how well they reach the test sites on the current network; apply the best in one tap

- Tests the same set the picker uses (Apply = select that strategy); the VPN is auto-paused for the run and restored after; targets reuse the bundled host list

## v0.13.9

- Remote-updatable ByeDPI strategies: refresh the set from the repo without an APK rebuild (fetched through mihomo when the VPN is up), with validation and last-good fallback. New "Update strategies" tile in ByeDpi settings (+ reset to bundled)

- Expand the bundled set to the full upstream romanvht/ByeByeDPI proxytest list (78 strategies, `{sni}` → google.com, raw blobs excluded); ranking is left to the in-app auto-test (planned)

## v0.13.8

- Data-driven ByeDPI strategies: the `ByeDpiPreset` enum is gone; strategies live solely in `assets/data/byedpi-strategies.json`, loaded at runtime. Updating/adding one is a pure JSON edit (no Dart/codegen/l10n)

- Strategy set is taken verbatim from upstream romanvht/ByeByeDPI `proxytest_strategies.list` (2026-05): `universal` is the maintainer's own default, the rest are the top usable entries (excluding `{sni}`/raw-blob lines we can't run) with neutral labels. No invented per-operator labeling

- On-disk override (no force-install) seams in a future remote refresh of the strategy set without a release

## v0.13.7

- Maintenance release: version bump, no functional changes since v0.13.6

## v0.13.6

- Bump libmihomo-android 0.1.1 -> 0.1.2

## v0.13.5

- Fix: proxies tab FAB pings the visible group instead of the persisted one

## v0.13.4

- Drop China-specific leftovers from default config; add Android connectivity probe coverage; enable sniffer by default

- Omit null override-destination in defaults

## v0.13.3

- Restore v0.12.0 DNS defaults; simplify IPv6 to a 2-state toggle

- Remove the fallback-filter setting; move Reset to an AppBar icon

- l10n cleanup (drop orphaned keys from the removed fallback-filter)

## v0.13.2

- Deep information-architecture restructure of settings, research-driven (settings audit PR1-PR5.9)

- Flatten single-tile tool sections; move Diagnostics to the bottom

- Strip desktop/dead code paths (ViewMode, NavigationItemMode, isMobile branches)

- dart_code_linter sweep + CI gate; skip APK build on pull requests

- Add 7 missing l10n entries

## v0.12.0

- Audit sweep: 59 findings + 4 carry-overs

- Add NEARBY_WIFI_DEVICES for Android 13+

- Fix YAML proxy-group order on tab bar

- One-banner permission CTA on network rules

- Tighten CI: PR triggers, format, fatal-infos, coverage, gitleaks, CodeQL

- Bump file_picker 10→11, permission_handler 11→12

- Backfill ja/zh_CN/ru l10n parity

- Pin libmihomo v0.1.1

## v0.11.1

- Force narrow byedpi host list on every app start

## v0.11.0

- Pure consumer pattern: native moves to libmihomo + libbyedpi

- Drop in-tree mihomo bridge

- Migrate ByeDPI to oviron/libbyedpi-android v0.1.0

- Rework logging architecture

## v0.10.0

- Add bydpi product flavor with in-tree ByeDPI

- ByeDPI: manual/auto mode + host-list whitelist

- Wire ByeDpiModule into VpnService via reflective load

- Add :byedpi Gradle module with libbyedpi.so

- Auto-create GitHub Release on tag

## v0.9.1

- Network rules: backfill VPN-default underlying-network gap

- Enforce 3-line comment cap across lib/ and android/

- Rewrite README as fork

- DNS: universal defaults for new profile

## v0.8.92

- Add sqlite store

- Optimize android quick action

- Optimize backup and restore

- Optimize more details

## v0.8.91

- Fix windows some issues

- Optimize overwrite handle

- Optimize access control page

- Optimize some details

## v0.8.90

- Fix android tile service

- Support append system DNS

- Fix some issues

- Update changelog

## v0.8.89

- Fix some issues

- Optimize Windows service mode

- Update core

- Update changelog

## v0.8.88

- Add android separates the core process

- Support core status check and force restart

- Optimize proxies page and access page

- Update flutter and pub dependencies

- Update go version

- Optimize more details

- Update changelog

## v0.8.87

- Optimize desktop view

- Optimize logs, requests, connection pages

- Optimize windows tray auto hide

- Optimize some details

- Update core

- Update changelog

## v0.8.86

- Fix windows tun issues

- Optimize android get system dns

- Optimize more details

- Update changelog

## v0.8.85

- Support override script

- Support proxies search

- Support svg display

- Optimize config persistence

- Add some scenes auto close connections

- Update core

- Optimize more details

## v0.8.84

- Fix windows service verify issues

- Update changelog

## v0.8.83

- Add windows server mode start process verify

- Add linux deb dependencies

- Add backup recovery strategy select

- Support custom text scaling

- Optimize the display of different text scale

- Optimize windows setup experience

- Optimize startTun performance

- Optimize android tv experience

- Optimize default option

- Optimize computed text size

- Optimize hyperOS freeform window

- Add developer mode

- Update core

- Optimize more details

- Add issues template

- Update changelog

## v0.8.82

- Optimize android vpn performance

- Add custom primary color and color scheme

- Add linux nad windows arm release

- Optimize requests and logs page

- Fix map input page delete issues

- Update changelog

## v0.8.81

- Add rule override

- Update core

- Optimize more details

- Update changelog

## v0.8.80

- Optimize dashboard performance

- Fix some issues

- Fix unselected proxy group delay issues

- Fix asn url issues

- Update changelog

## v0.8.79

- Fix tab delay view issues

- Fix tray action issues

- Fix get profile redirect client ua issues

- Fix proxy card delay view issues

- Add Russian, Japanese adaptation

- Fix some issues

- Update changelog

## v0.8.78

- Fix list form input view issues

- Fix traffic view issues

- Update changelog

## v0.8.77

- Optimize performance

- Update core

- Optimize core stability

- Fix linux tun authority check error

- Fix some issues

- Fix scroll physics error

- Update changelog

## v0.8.75

- Add windows storage corruption detection

- Fix core crash caused by windows resource manager restart

- Optimize logs, requests, access to pages

- Fix macos bypass domain issues

- Update changelog

## v0.8.74

- Fix some issues

- Update changelog

## v0.8.73

- Update popup menu

- Add file editor

- Fix android service issues

- Optimize desktop background performance

- Optimize android main process performance

- Optimize delay test

- Optimize vpn protect

- Update changelog

## v0.8.72

- Update core

- Fix some issues

- Update changelog

## v0.8.71

- Remake dashboard

- Optimize theme

- Optimize more details

- Update flutter version

- Update changelog

## v0.8.70

- Support better window position memory

- Add windows arm64 and linux arm64 build script

- Optimize some details

## v0.8.69

- Remake desktop

- Optimize change proxy

- Optimize network check

- Fix fallback issues

- Optimize lots of details

- Update change.yaml

- Fix android tile issues

- Fix windows tray issues

- Support setting bypassDomain

- Update flutter version

- Fix android service issues

- Fix macos dock exit button issues

- Add route address setting

- Optimize provider view

- Update changelog

- Update CHANGELOG.md

## v0.8.67

- Add android shortcuts

- Fix init params issues

- Fix dynamic color issues

- Optimize navigator animate

- Optimize window init

- Optimize fab

- Optimize save

## v0.8.66

- Fix the collapse issues

- Add fontFamily options

## v0.8.65

- Update core version

- Update flutter version

- Optimize ip check

- Optimize url-test

## v0.8.64

- Update release message

- Init auto gen changelog

- Fix windows tray issues

- Fix urltest issues

- Add auto changelog

- Fix windows admin auto launch issues

- Add android vpn options

- Support proxies icon configuration

- Optimize android immersion display

- Fix some issues

- Optimize ip detection

- Support android vpn ipv6 inbound switch

- Support log export

- Optimize more details

- Fix android system dns issues

- Optimize dns default option

- Fix some issues

- Update readme

## v0.8.60

- Fix build error2

- Fix build error

- Support desktop hotkey

- Support android ipv6 inbound

- Support android system dns

- fix some bugs

## v0.8.59

- Fix delete profile error

## v0.8.58

- Fix submit error 2

- Fix submit error

- Optimize DNS strategy

- Fix the problem that the tray is not displayed in some cases

- Optimize tray

- Update core

- Fix some error

## v0.8.57

- Fix tun update issues

- Add DNS override
- Fixed some bugs
- Optimize more detail

- Add Hosts override

## v0.8.56

- fix android tip error
- fix windows auto launch error

## v0.8.55

- Fix windows tray issues

- Optimize windows logic

- Optimize app logic

- Support windows administrator auto launch

- Support android close vpn

## v0.8.53

- Change flutter version

- Support profiles sort

- Support windows country flags display

- Optimize proxies page and profiles page columns

## v0.8.52

- Update flutter version

- Update version

- Update timeout time

- Update access control page

- Fix bug

## v0.8.51

- Optimize provider page

- Optimize delay test

- Support local backup and recovery

- Fix android tile service issues

## v0.8.49

- Fix linux core build error

- Add proxy-only traffic statistics

- Update core

- Optimize more details

- Merge pull request #140 from txyyh/main

- 添加自建 F-Droid 仓库相关 workflow
- Rename readme fingerprint

- Rename workflow deploy repo name

- Add download guide to README

- Add push release files to fdroid-repo

## v0.8.48

- Optimize proxies page

- Fix ua issues

- Optimize more details

## v0.8.47

- Fix windows build error

## v0.8.46

- Update app icon

- Fix desktop backup error

- Optimize request ua

- Change android icon

- Optimize dashboard

## v0.8.44

- Remove request validate certificate

- Sync core

## v0.8.43

- Fix windows error

## v0.8.42

- Fix setup.dart error

- Fix android system proxy not effective

- Add macos arm64

## v0.8.41

- Optimize proxies page

- Support mouse drag scroll

- Adjust desktop ui

- Revert "Fix android vpn issues"

- This reverts commit 891977408e6938e2acd74e9b9adb959c48c79988.

## v0.8.40

- Fix android vpn issues

- Fix android vpn issues

- Rollback partial modification

## v0.8.39

- Fix the problem that ui can't be synchronized when android vpn is occupied by an external

- Override default socksPort,port

## v0.8.38

- Fix fab issues

## v0.8.37

- Update version

- Fix the problem that vpn cannot be started in some cases

- Fix the problem that geodata url does not take effect

## v0.8.36

- Update ua

- Fix change outbound mode without check ip issues

- Separate android ui and vpn

- Fix url validate issues 2

- Add android hidden from the recent task

- Add geoip file

- Support modify geoData URL

## v0.8.35

- Fix url validate issues

- Fix check ip performance problem

- Optimize resources page

## v0.8.34

- Add ua selector

- Support modify test url

- Optimize android proxy

- Fix the error that async proxy provider could not selected the proxy

## v0.8.33

- Fix android proxy error

- Fix submit error

- Add windows tun

- Optimize android proxy

- Optimize change profile

- Update application ua

- Optimize delay test

## v0.8.32

- Fix android repeated request notification issues

## v0.8.31

- Fix memory overflow issues

## v0.8.30

- Optimize proxies expansion panel 2

- Fix android scan qrcode error

## v0.8.29

- Optimize proxies expansion panel

- Fix text error

## v0.8.28

- Optimize proxy

- Optimize delayed sorting performance

- Add expansion panel proxies page

- Support to adjust the proxy card size

- Support to adjust proxies columns number

- Fix autoRun show issues

- Fix Android 10 issues

- Optimize ip show

## v0.8.26

- Add intranet IP display

- Add connections page

- Add search in connections, requests

- Add keyword search in connections, requests, logs

- Add basic viewing editing capabilities

- Optimize update profile

## v0.8.25

- Update version

- Fix the problem of excessive memory usage in traffic usage.

- Add lightBlue theme color

- Fix start unable to update profile issues

- Fix flashback caused by process

## v0.8.23

- Add build version

- Optimize quick start

- Update system default option

## v0.8.22

- Update build.yml

- Fix android vpn close issues

- Add requests page

- Fix checkUpdate dark mode style error

- Fix quickStart error open app

- Add memory proxies tab index

- Support hidden group

- Optimize logs

- Fix externalController hot load error

## v0.8.21

- Add tcp concurrent switch

- Add system proxy switch

- Add geodata loader switch

- Add external controller switch

- Add auto gc on trim memory

- Fix android notification error

## v0.8.20

- Fix ipv6 error

- Fix android udp direct error

- Add ipv6 switch

- Add access all selected button

- Remove android low version splash

## v0.8.19

- Update version

- Add allowBypass

- Fix Android only pick .text file issues

## v0.8.18

- Fix search issues

## v0.8.17

- Fix LoadBalance, Relay load error

- Fix build.yml4

- Fix build.yml3

- Fix build.yml2

- Fix build.yml

- Add search function at access control

- Fix the issues with the profile add button to cover the edit button

- Adapt LoadBalance and Relay

- Add arm

- Fix android notification icon error

## v0.8.16

- Add one-click update all profiles
- Add expire show

## v0.8.15

- Temp remove tun mode

- Remove macos in workflow

- Change go version

## v0.8.14

- Update Version

- Fix tun unable to open

## v0.8.13

- Optimize delay test2

- Optimize delay test

- Add check ip

- add check ip request

## v0.8.12

- Fix the problem that the download of remote resources failed after GeodataMode was turned on, which caused the
  application to flash back.

- Fix edit profile error

- Fix quickStart change proxy error

- Fix core version

## v0.8.10

- Fix core version

## v0.8.9

- Update file_picker

- Add resources page

- Optimize more detail

- Add access selected sorted

- Fix notification duplicate creation issue

- Fix AccessControl click issue

## v0.8.7

- Fix Workflow

- Fix Linux unable to open

- Update README.md 3

- Create LICENSE
- Update README.md 2

- Update README.md

- Optimize workFlow

## v0.8.6

- optimize checkUpdate

## v0.8.5

- Fix submit error

## v0.8.4

- add WebDAV

- add Auto check updates

- Optimize more details

- optimize delayTest

## v0.8.2

- upgrade flutter version

## v0.8.1

- Update kernel
- Add import profile via QR code image

## v0.8.0

- Add compatibility mode and adapt clash scheme.

## v0.7.14

- update Version

- Reconstruction application proxy logic

## v0.7.13

- Fix Tab destroy error

## v0.7.12

- Optimize repeat healthcheck

## v0.7.11

- Optimize Direct mode ui

## v0.7.10

- Optimize Healthcheck

- Remove proxies position animation, improve performance
- Add Telegram Link

- Update healthcheck policy

- New Check URLTest

- Fix the problem of invalid auto-selection

## v0.7.8

- New Async UpdateConfig

- add changeProfileDebounce

- Update Workflow

- Fix ChangeProfile block

- Fix Release Message Error

## v0.7.7

- Update Selector 2

## v0.7.6

- Update Version

- Fix Proxies Select Error

## v0.7.5

- Fix the problem that the proxy group is empty in global mode.

- Fix the problem that the proxy group is empty in global mode.

## v0.7.4

- Add ProxyProvider2

## v0.7.3

- Add ProxyProvider

- Update Version

- Update ProxyGroup Sort

- Fix Android quickStart VpnService some problems

## v0.7.1

- Update version

- Set Android notification low importance

- Fix the issue that VpnService can't be closed correctly in special cases

- Fix the problem that TileService is not destroyed correctly in some cases

- Adjust tab animation defaults

- Add Telegram in README_zh_CN.md

- Add Telegram

## v0.7.0

- update mobile_scanner

- Initial commit