## FlClash (oviron fork)

[![License](https://img.shields.io/github/license/oviron/FlClash?style=flat-square)](LICENSE) [![Last Version](https://img.shields.io/github/release/oviron/FlClash/all.svg?style=flat-square)](https://github.com/oviron/FlClash/releases/)

Android `mihomo` client. Open source, no ads, no telemetry.

A maintained fork of [chen08209/FlClash](https://github.com/chen08209/FlClash) (last upstream activity: February 2026). This fork is **Android-only**: desktop platform code, Firebase/Crashlytics, the in-app updater, the External Controller toggle, and other upstream-specific layers were removed. The mihomo core was migrated from chen's submodule to `metacubex/mihomo v1.19.24` directly, and the client now talks to mihomo through a 100% JNI bridge (no REST controller). The bridge itself lives in a separate public repo [oviron/libmihomo-android](https://github.com/oviron/libmihomo-android) and is consumed here as a SHA-256-pinned `.aar` download.

<p align="center">
    <img alt="mobile" src="snapshots/mobile.gif" width="45%">
</p>

## What's in this fork

- **Per-profile App Access Control:** YAML `tun.include-package` / `tun.exclude-package` are honored by `VpnService.Builder.addAllowedApplication()`. Without this, Android Auto breaks on whitelist profiles. A per-profile GUI editor with drift v2 migration, opt-in override (Profile UI > YAML > Global), and Reset-to-YAML are included.
- **Network Rules v1:** automatic VPN on/off based on the current network (WifiNamed / AnyWifi / AnyCellular).
- **H.7 backend:** `metacubex/mihomo v1.19.24` direct, with CMfA-style patterns: type-explicit providers API, async-callback path, push subscription for connections/log, INNER-bypass via Dart pre-process.
- **Dashboard checkIp probe:** JNI `WithSpecialProxy` bypasses user rules so the real exit-IP shows even on whitelist profiles with `MATCH,REJECT`.
- Stability stack: wake/Wi-Fi locks, idempotent module loader, defensive Go type-assertions, MATCH-rule guard for upstream #1959, Global proxy watchdog.

## Install

`./gradlew` is not used directly; APKs are produced by the GitHub Actions workflow in this repo.

```bash
adb install -r FlClash-<version>-android-arm64-v8a.apk
```

Releases are published under [Releases](https://github.com/oviron/FlClash/releases/) and signed with this fork's own debug keystore. Reinstalling on top of upstream-signed FlClash requires a clean reinstall once (signatures differ).

## Build

```bash
git clone https://github.com/oviron/FlClash.git
cd FlClash
dart setup.dart android
```

Requires Flutter, Android SDK + NDK 28. The build script downloads a SHA-256-pinned `libmihomo-android-<version>.aar` from GitHub Releases, extracts `libclash.so` per ABI, and produces split APKs for `arm`, `arm64`, and `x86_64` in `dist/`.

## License

GPL-3.0, inherited from [chen08209/FlClash](https://github.com/chen08209/FlClash). See [LICENSE](LICENSE).

## Acknowledgements

- [chen08209/FlClash](https://github.com/chen08209/FlClash) — original FlClash app.
- [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) — proxy core.
- [kr328/ClashMetaForAndroid](https://github.com/MetaCubeX/ClashMetaForAndroid) — reference patterns for the JNI bridge.
