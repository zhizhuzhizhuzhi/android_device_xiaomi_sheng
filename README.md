# Xiaomi Pad 6S Pro 12.4 (sheng)

Unofficial device support.

AOSPA Calcite / Android 17 device configuration. Product `aospa_sheng`,
release `cp2a`; `user` and `userdebug` use separate output directories.

## Source setup

Use the matching `android_local_manifests` repository on branch `calcite`.
It pins the Android projects, shared-platform delta and both common trees.
The device history starts from xiaomi-sm8550-devs' sheng configuration;
existing LineageOS, AOSPA and other source copyright headers are retained.

## Proprietary and kernel inputs

The matching hardware baseline is **Sheng Global OS3.0.6.0.WNXMIXM / Android 16**.
This source repository does not redistribute its kernel, firmware or closed
libraries. `device-inputs.json` records their paths, SHA256 and deterministic
fixups. Resource PNGs are ordinary checked-in overlay assets.

Prepare a local partition dump, kernel payload and pinned QSPM input, then build
the Caps Lock module as described in keyboard/README.md before extraction:

```sh
python3 device/xiaomi/sheng/tools/extract-device-inputs.py --tree "$PWD" \
  --source /path/to/stock-dump --source /path/to/kernel-payload \
  --source /path/to/oneplus-common --source "$PWD" \
  --built-capslock out-sheng-capslock/module/hid-nanosic-capslock.ko \
  --patchelf prebuilts/extract-tools/linux-x86/bin/patchelf-0_17_2
```

This verifies every input and applies the DisplayFeature/Dolby ELF fixups.
It refuses unexpected existing files and wrong input hashes. The Caps Lock
module is built separately; see `keyboard/README.md`. Run the standard
`extract-files.py` to populate the two vendor trees, then follow the manifest
repository's integration instructions. See `tools/prepare-kernel-payload.py`
for boot/vendor_boot/DLKM input layout.

## Build

```sh
bash build-device.sh sheng user -j8 target-files-package
# or: bash build-device.sh sheng userdebug -j8 target-files-package
```

The helpers select `aospa_sheng`, `cp2a` and the requested variant directly.
They do not run repository synchronization or download proprietary inputs.
The historical patches under `patches/` document bring-up; use the pinned
integration delta rather than applying both patch collections.

## License

Most device configuration is Apache-2.0. The Caps Lock kernel driver and its
kernel build material are GPL-2.0-only. Per-file notices, including UAPI syscall
exceptions, take precedence. Proprietary inputs are not covered by `LICENSE`.
