# Xiaomi Pad 6S Pro 12.4 (sheng)

Unofficial AOSPA Calcite / Android 17 device configuration, product
`aospa_sheng`, release `cp2a`. The matching full manifest is `sheng.xml`
in `zhizhuzhizhuzhi/android_local_manifests` on branch `calcite`.

## Source and vendor preparation

The manifest checks out modified framework, HAL, kernel and service projects
at their committed revisions. No system patch preparation step is required.
Use Sheng Global OS3.0.6.0.WNXMIXM / Android 16. Extract proprietary files from the matching local stock dump:

```sh
python3 device/xiaomi/sheng/extract-files.py /path/to/stock-dump
```

The extraction entry also writes the device's reviewed vendor metadata and text
fixups. `build/vendor-config.json` records those files and hashes. Do not run a
separate system patch installer. Vendor repositories contain their own build
metadata; generated closed inputs retain their original licenses.

Use `tools/extract-device-inputs.py` with the local stock/prepared input roots
to populate the additional hash-pinned inputs in `device-inputs.json` and its
includes. Its `--verify` mode checks all required input hashes. Stock extraction
alone does not provide every compatible dependency.

Sheng additionally requires its extracted kernel payload and separately built
Caps Lock module; see `keyboard/README.md` and `tools/prepare-kernel-payload.py`.
After populating device inputs, run
`python3 device/xiaomi/sheng/displayfeature/apply-compat-libraries.py` to copy
the checked ABI-compatible libraries into the extracted vendor tree.

## Build

```sh
bash build-device.sh sheng user -j8 target-files-package
```

The shared wrapper selects the product, `cp2a` and requested variant. Fuxi's
source kernel is prepared before the Android build. `OUT_DIR` selects a separate
relative output directory. System source changes live in their owning projects.

## License

Original AOSPA, LineageOS and other per-file attribution is retained. Device
configuration is generally Apache-2.0; kernel code and modules follow their own
GPL/UAPI notices. Extracted proprietary files retain their original licenses.
