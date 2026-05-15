# ByeDPI integration plan

Branch: `feat/byedpi-integration`. Target: v0.10.0.

## Goal

Ship FlClash in two build flavors:

- `classic`: unchanged from v0.9.1.
- `bydpi`: bundles `libbyedpi.so` (DPI bypass SOCKS5 proxy from hufrea/byedpi). FlClash owns ByeDPI lifecycle alongside the VPN tunnel, and the profile YAML is rewritten on the fly to route user-defined Bypass Profiles (domain + app sets) through a local SOCKS5 listener with VPN fallback.

Replaces the current workflow where the user runs `romanvht/ByeByeDPI` as a separate APK and hardcodes `byedpi-local` + `YT-DPI-OR-VPN` in profile YAML.

## Architecture

```
android/
  app/                productFlavors: classic, bydpi
  byedpi/   (new)     libbyedpi.so + JNI + Kotlin facade + ByeDpiModule
  service/            VpnService.moduleLoader loads ByeDpiModule reflectively
  common/             Module + ModuleLoader (moved from :service)
  core/

lib/
  byedpi/   (new)     BypassProfile model, presets, engine, repo
  providers/byedpi.dart
  views/setting/byedpi.dart + widgets/byedpi_*.dart
  views/tools.dart    + _ByeDpiItem (gated by --dart-define=BYDPI=true)
  common/task.dart    injectByeDpiConfig in _makeRealProfileTask
```

Build flavor logic:

- `:byedpi` is always listed in `settings.gradle.kts`. Only the `bydpi` flavor wires it via `bydpiImplementation(project(":byedpi"))`. Classic flavor ships no `libbyedpi.so`.
- `:service` does not depend on `:byedpi`. It uses `Class.forName("com.follow.clash.byedpi.ByeDpiModule")` to load the module reflectively. Classic flavor: `ClassNotFoundException` is caught, module is `null`, loader skips it.
- `Module` and `ModuleLoader` move from `:service/modules/` to `:common/modules/` so `:byedpi` can implement `Module` without a circular dependency.

Universal Bypass Profiles:

- One ByeDPI instance on `127.0.0.1:1080` with one global CLI args string (v1).
- N user-defined `BypassProfile { name, enabled, domains, apps }`. Bundled presets: YouTube, Discord, Twitch.
- `_makeRealProfileTask` injects: one `byedpi-local` socks5 proxy + for each enabled profile P a `<P>-route` fallback group, a `<P>-rules` sub-rule with `DOMAIN-SUFFIX` entries, and `SUB-RULE,(PROCESS-NAME,<app>),<P>-rules` references.

Per-profile ByeDPI strategy (different CLI per profile via byedpi `--auto-mode per-group`) is deferred to v2.

## Steps

### Phase 1: `:byedpi` Gradle module

1.1. Add `include(":byedpi")` to `android/settings.gradle.kts`.

1.2. Create `android/byedpi/build.gradle.kts`: `com.android.library`, namespace `com.follow.clash.byedpi`, externalNativeBuild via CMake, abiFilters `[arm64-v8a, armeabi-v7a, x86_64]`.

1.3. `android/byedpi/src/main/AndroidManifest.xml`: empty `<manifest/>`.

1.4. Add submodule: `git submodule add https://github.com/hufrea/byedpi android/byedpi/src/main/cpp/byedpi`, pinned to commit `ba532298` (same SHA as romanvht/ByeByeDPI v1.7.5).

1.5. `android/byedpi/src/main/cpp/CMakeLists.txt`: glob `byedpi/*.c` minus `win_service.c`, add `native-lib.c`, define `ANDROID_APP`, link `android` and `log`, release flags `-O3 -flto -fno-exceptions -fno-rtti`.

1.6. `android/byedpi/src/main/cpp/native-lib.c`: three JNI functions for `com.follow.clash.byedpi.ByeDpiProxy` (`nativeStart(args)`, `nativeStop()`, `nativeForceClose()`). Internal `g_proxy_running` guard and `reset_params() + optind = 1` between runs. Adapted from `romanvht/ByeByeDPI/app/src/main/cpp/native-lib.c`.

1.7. `android/byedpi/src/main/java/com/follow/clash/byedpi/ByeDpiProxy.kt`: singleton, `System.loadLibrary("byedpi")` in companion init. Suspend `start(args: List<String>)` runs `nativeStart` on `Dispatchers.IO`. `stop()` and `forceClose()` are immediate.

1.8. `android/byedpi/src/main/java/com/follow/clash/byedpi/ByeDpiArgs.kt`: build `Array<String>` from a serializable config (port, raw CLI string).

1.9. `android/byedpi/src/main/java/com/follow/clash/byedpi/ByeDpiState.kt`: SharedPreferences holder in `:remote` process. Keys: `byedpi_enabled` (Boolean), `byedpi_port` (Int, default 1080), `byedpi_cli_args` (String). Dart writes via a MethodChannel handler that we add in Phase 4.

**Verify**: `./gradlew :byedpi:assembleRelease`. Inspect `byedpi/build/outputs/aar/byedpi-release.aar`: three `.so` files under `jni/<abi>/`.

### Phase 2: Service integration

2.1. Move `Module.kt` and `ModuleLoader.kt` from `android/service/src/main/java/com/follow/clash/service/modules/` to `android/common/src/main/java/com/follow/clash/common/modules/`. Update package and imports in `NetworkObserveModule`, `NotificationModule`, `SuspendModule`, `VpnService`, and any other caller.

2.2. `android/byedpi/.../ByeDpiModule.kt`: `class ByeDpiModule(ctx: Context) : Module()`. `onInstall()`: read `ByeDpiState`, if enabled, launch `ByeDpiProxy.start(args)` on an `IO` scope. `onUninstall()`: `ByeDpiProxy.stop()`.

2.3. `android/service/.../VpnService.kt`: extend `moduleLoader` block with `tryByeDpiModule(self)?.let { install(it) }`. Helper uses `Class.forName(...)` and catches `ClassNotFoundException`.

**Verify**: `./gradlew :app:assembleBydpiDebug :app:assembleClassicDebug`. Both must succeed.

### Phase 3: Build flavors and CI

3.1. `android/app/build.gradle.kts`: add `flavorDimensions += "variant"`, `productFlavors { create("classic") {}; create("bydpi") { applicationIdSuffix = ".bydpi"; versionNameSuffix = "-bydpi"; buildConfigField("Boolean", "BYDPI_ENABLED", "true") } }`, `buildFeatures { buildConfig = true }`. In `defaultConfig`: `buildConfigField("Boolean", "BYDPI_ENABLED", "false")`. In `dependencies`: `"bydpiImplementation"(project(":byedpi"))`.

3.2. `setup.dart`: accept `--flavor <classic|bydpi>` and forward to `flutter build apk --flavor $flavor --dart-define=BYDPI=$enabled`. Default flavor: `classic`.

3.3. `.github/workflows/build.yaml`: matrix `flavor: [classic, bydpi]`, propagate to setup.dart. Artifacts named `FlClash-<flavor>-<version>-android-<abi>.apk`.

**Verify**: Build both flavors locally. `unzip -l build/app/outputs/flutter-apk/app-classic-release.apk | grep byedpi` returns nothing. The bydpi APK contains `lib/<abi>/libbyedpi.so`.

### Phase 4: Dart UI and profile injection

4.1. `lib/byedpi/model.dart`: freezed `BypassProfile { id, name, enabled, domains: List<String>, apps: List<String> }` and `ByeDpiSettings { enabled, port, cliArgs, fallbackGroup }`. JSON codec following the `NetworkRule` shape from `lib/network_rules/model.dart`.

4.2. `lib/byedpi/presets.dart`: built-in profiles. YouTube (5 domains x 4 apps from existing `mihomo-mobile.yaml::yt-app-route`), Discord (3 domains x 1 app), Twitch (2 domains x 1 app).

4.3. `lib/byedpi/repository.dart`: Drift table `bypass_profiles` (id PK, name, enabled, domains TEXT JSON, apps TEXT JSON, sort_order INTEGER). Repo with CRUD + stream + reorder.

4.4. `lib/byedpi/engine.dart`: pure-Dart `injectByeDpiConfig(rawConfig, settings, profiles, fallbackGroup) -> rawConfig`. Adds `byedpi-local` socks5 proxy, per-profile fallback groups and sub-rules. No-op if settings.enabled is false or profiles list is empty.

4.5. `lib/providers/byedpi.dart`: Riverpod state. `ByeDpiSettingsNotifier`, `bypassProfilesStreamProvider`, `byeDpiRepoProvider`. State writes to Android MethodChannel `com.follow.clash/byedpi` so `:remote` process sees updates.

4.6. `lib/views/setting/byedpi.dart`: settings page. `_MasterToggleCard`, `_CliArgsField`, `_ProfilesList` (reorderable). Mirrors `lib/views/setting/network_rules.dart`.

4.7. `lib/views/setting/widgets/byedpi_profile_card.dart`, `edit_byedpi_profile_dialog.dart`. Mirror `rule_card.dart` and `edit_rule_dialog.dart`.

4.8. `lib/views/tools.dart`: add `if (kByeDpiEnabled) const _ByeDpiItem()` inside `_getSettingList()`. `kByeDpiEnabled = bool.fromEnvironment('BYDPI')` declared in `lib/common/`.

4.9. `lib/models/profile.dart` and `lib/providers/state.dart::setupState`: include `byeDpiSettings` and `bypassProfiles` in `MakeRealProfileState`.

4.10. `lib/common/task.dart::_makeRealProfileTask`: after INNER bypass injection, call `injectByeDpiConfig(rawConfig, settings, profiles, fallbackGroup)` when state.byeDpiEnabled.

4.11. l10n strings (en, ru, zh-CN, ja) for ByeDPI UI.

4.12. NOTICES in About screen: ByeDPI MIT attribution and the pinned commit SHA.

**Verify**: end-to-end smoke on the phone (manual). Install bydpi APK, toggle ByeDPI on, start VPN, open YouTube, `adb logcat | grep byedpi` shows native logs, traffic for YouTube domains hits 127.0.0.1:1080.

## Verification matrix

| Check | Command | Expected |
|---|---|---|
| classic flavor parity | install classic over v0.9.1 | upgrade succeeds, no ByeDPI UI |
| classic flavor size | `du -sh app-classic-release.apk` | ~25 MB |
| bydpi flavor size | `du -sh app-bydpi-release.apk` | ~25.5 MB |
| classic isolation | `unzip -p app-classic.apk classes.dex \| strings \| grep -c ByeDpiModule` | 0 |
| bydpi presence | same command for bydpi APK | >=1 |
| YAML injection | `adb shell run-as com.follow.clash.bydpi cat files/profiles/<id>.yaml` | contains byedpi-local + `<profile>-route` |
| End-to-end smoke | start VPN, open YouTube | works without separate ByeByeDPI app |

## Maintenance

- ByeDPI submodule SHA bumped manually when new techniques land upstream. Expected cadence: 1.5h per quarter.
- Dual-flavor CI doubles the build matrix (3 ABIs x 2 flavors = 6 APKs). Acceptable.
- Track upstream `metacubex/mihomo` and `hufrea/byedpi` separately. Both have stable public APIs.

## Out of scope (v2 candidates)

- Per-profile ByeDPI strategy via `--auto-mode per-group`.
- Auto-update of byedpi submodule.
- iOS / desktop. FlClash fork is Android-only.

## Source research

Multi-agent investigation (5 angles, cross-validation, synthesis) lives in the operator workspace, not in this repo. Key conclusions are folded into this plan.
