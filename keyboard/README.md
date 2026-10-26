# Nanosic Caps Lock driver

The HID driver translates standard LED_CAPSL events into the Sheng keyboard
indicator command. It uses workqueues and resume notifications, without a timer
or periodic scan. VID/PID matching is limited to 15d9:00a3.

## Build

Sync the pinned kernel and clang-r450784e projects from the manifest. The module
uses GKI common commit b00609b259a508cef1e5053928c94f3efc7d13f7. The SHA256-pinned
kernel configuration and Module.symvers are in `build-inputs/`.

```sh
bash device/xiaomi/sheng/keyboard/build-capslock.sh "$PWD"
```

The script prepares a separate output tree and builds only the module; it never
builds or replaces the stock boot kernel. Install a rebuilt module explicitly with:

```sh
python3 device/xiaomi/sheng/tools/extract-device-inputs.py --tree "$PWD" \
  --built-capslock out-sheng-capslock/module/hid-nanosic-capslock.ko \
  --source /path/to/kernel-payload --source /path/to/stock-dump
```

The explicit module option validates the reviewed C source hash, AArch64 ELF,
module name, VID/PID alias, vermagic and all imported symbol CRCs. It records
whether bytes match the reference module; ABI agreement is not reported as
byte identity. Other proprietary input hashes remain strict.

Load it before nanosic_driver.ko. Keep the stock Nanosic and Xiaomi transport
modules. Source and build material retain GPL-2.0; do not force module loading.
