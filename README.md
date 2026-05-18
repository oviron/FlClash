## FlClash (oviron fork)

[![License](https://img.shields.io/github/license/oviron/FlClash?style=flat-square)](LICENSE) [![Last Version](https://img.shields.io/github/release/oviron/FlClash/all.svg?style=flat-square)](https://github.com/oviron/FlClash/releases/)

Android `mihomo` client. Open source, no ads, no telemetry.

A maintained fork of [chen08209/FlClash](https://github.com/chen08209/FlClash) (last upstream activity: February 2026). **Android-only**, `metacubex/mihomo v1.19.24` direct via 100% JNI, no REST controller. The mihomo bridge lives in [oviron/libmihomo-android](https://github.com/oviron/libmihomo-android); the DPI-bypass core lives in [oviron/libbyedpi-android](https://github.com/oviron/libbyedpi-android). FlClash consumes both as SHA-256 + GPG-pinned `.aar` downloads — no C/C++/Go code in this repo.

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

## Development

Pre-commit hook runs `dart format --set-exit-if-changed` and `flutter analyze --fatal-infos` on staged Dart files. Install once after cloning:

```bash
ln -s ../../scripts/pre-commit.sh .git/hooks/pre-commit
```

CI enforces the same checks plus `flutter test`, `detekt` on Kotlin sources, `gitleaks` secret scan, and CodeQL on every push and PR to `main`.

## License

GPL-3.0, inherited from [chen08209/FlClash](https://github.com/chen08209/FlClash). See [LICENSE](LICENSE).

## Acknowledgements

- [chen08209/FlClash](https://github.com/chen08209/FlClash) — original FlClash app.
- [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) — proxy core.
- [kr328/ClashMetaForAndroid](https://github.com/MetaCubeX/ClashMetaForAndroid) — reference patterns for the JNI bridge.
