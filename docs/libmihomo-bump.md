# Bumping libmihomo-android

This is the procedure to bump the pinned [oviron/libmihomo-android](https://github.com/oviron/libmihomo-android) bridge consumed by `setup.dart`. The .aar is SHA-256-pinned in source and exposes its API surface through `android/core/src/main/cpp/vendored/libclash.h`; both have to move together.

Run through the checklist for every libmihomo release you adopt.

## 1. Confirm the upstream release is ready

```sh
gh release view vX.Y.Z --repo oviron/libmihomo-android
gh release view vX.Y.Z --repo oviron/libmihomo-android --json assets \
  | jq -r '.assets[] | "\(.size)\t\(.name)"'
```

Expect three assets: `libmihomo-android-vX.Y.Z.aar`, `.aar.sha256`, `.aar.asc`. Workflow status must be green.

## 2. Regenerate the cgo header from upstream source

`vendored/libclash.h` is hand-merged from `go tool cgo` output across all three ABIs. Pull the matching libmihomo source tree, run cgo locally, capture the per-ABI headers.

```sh
git -C ~/dev/libmihomo-android fetch --tags
git -C ~/dev/libmihomo-android checkout vX.Y.Z
ANDROID_NDK=$HOME/Library/Android/sdk/ndk/28.0.13004108 \
  ~/dev/libmihomo-android/build-native.sh
find ~/dev/libmihomo-android/src/main/jniLibs -name libclash.h
```

`build-native.sh` writes the cgo-generated headers next to each `libclash.so`. Inspect them.

## 3. Diff per-ABI and confirm the only differences are the LP64 block

```sh
diff -u ~/dev/libmihomo-android/src/main/jniLibs/arm64-v8a/libclash.h \
        ~/dev/libmihomo-android/src/main/jniLibs/armeabi-v7a/libclash.h
```

Expected differences are limited to `typedef GoInt64 GoInt;` vs `typedef GoInt32 GoInt;` and the matching `_check_for_..._pointer_matching_GoInt` assertion. If anything else differs — stop, surface the discrepancy, do not proceed.

## 4. Hand-merge into vendored/libclash.h

Update `android/core/src/main/cpp/vendored/libclash.h`:

- Replace the `extern` declarations at the bottom with the new symbol list from any per-ABI cgo output (they are identical across ABIs).
- Keep the `__LP64__` gating around `GoInt`/`GoUint`; replace the generic `_check_for_pointer_matching_GoInt` only if upstream cgo changed its shape.
- Bump `#define LIBCLASH_EXPECTED_BRIDGE_ABI N` if libmihomo bumped `bridgeABI()`.

## 5. Update the pin in setup.dart

```sh
shasum -a 256 ~/dev/libmihomo-android/path/to/libmihomo-android-vX.Y.Z.aar
# or:
gh release download vX.Y.Z --repo oviron/libmihomo-android --pattern '*.sha256' --dir /tmp/rel --clobber
cat /tmp/rel/*.sha256
```

Edit `setup.dart`:

- `_libmihomoVersion = 'X.Y.Z'`
- `_libmihomoSha256 = '<sha256 from above>'`
- The URL constant follows the version automatically.

## 6. If libmihomo bumped bridgeABI, bump the Kotlin stub

`android/core/src/main/java/com/follow/clash/core/Core.kt`: `EXPECTED_BRIDGE_ABI = N`. Without this, the runtime check in `Core.init` will refuse to start the VPN service (which is the desired behaviour — it surfaces the mismatch immediately rather than crashing at first JNI call).

## 7. Sanity build

```sh
rm -rf libclash/ android/core/src/main/jniLibs/ android/core/.cxx/
dart run setup.dart android --arch=arm64 --flavor=bydpi
```

Expect:

- `downloaded N bytes, SHA-256 verified: …`
- `extracted jni/<abi>/libclash.so -> …` for all three ABIs
- `Built build/app/outputs/flutter-apk/app-arm64-v8a-bydpi-release.apk`
- `unzip -l dist/FlClash-bydpi-…apk | grep libclash.so` matches the upstream `.so` size byte-for-byte (modulo zip headers).

Then:

```sh
unzip -p dist/FlClash-bydpi-…-arm64-v8a.apk lib/arm64-v8a/libclash.so \
  | nm -D /dev/stdin | grep ' T ' | wc -l
```

The count must equal libmihomo's documented `//export` count (11 in v0.1.0). Drift here means the vendored header is out of sync with the .so.

## When NOT to use this procedure

- libmihomo released a patch with **no header changes** (e.g. dependency bump, internal refactor): skip steps 2-4, only update the pin in step 5. Verify by reading the upstream CHANGELOG and confirming `bridgeABI` is unchanged.
- libmihomo broke an existing `//export` signature: don't bump until you also update FlClash call sites (`Core.kt`, `core.cpp`, `VpnService.kt`) — and bump `bridgeABI` upstream first so the runtime check catches stub-vs-.so drift.
