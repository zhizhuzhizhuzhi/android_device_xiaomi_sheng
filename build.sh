#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
set -eo pipefail
tree=$(realpath "${1:?Usage: build.sh SHARED_ANDROID_TREE [goal]}")
goal=${2:-target-files-package}
jobs=()
if [ -n "${SHENG_BUILD_JOBS:-}" ]; then jobs=(-j"$SHENG_BUILD_JOBS"); fi
targets=("$goal")
if [[ "$goal" == boot-images ]]; then
    targets=()
    for image in boot init_boot vendor_boot dtbo system_dlkm vendor_dlkm recovery; do
        targets+=("out-sheng-userdebug/target/product/sheng/$image.img")
    done
fi
exec bash "$tree/device/xiaomi/sm8550-platform-common/build.sh" "$tree" sheng userdebug "${jobs[@]}" "${targets[@]}"
