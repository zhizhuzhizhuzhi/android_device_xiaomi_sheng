#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only
set -euo pipefail
here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
tree=$(realpath "${1:?Usage: build-capslock.sh ANDROID_ROOT [OUTPUT_DIRECTORY]}")
output=$(realpath -m "${2:-$tree/out-sheng-capslock}")
source="$tree/kernel_platform/common"
expected=b00609b259a508cef1e5053928c94f3efc7d13f7
test "$(git -C "$source" rev-parse HEAD)" = "$expected"
test -z "$(git -C "$source" status --porcelain --untracked-files=no)"
export PATH="$tree/kernel_platform/prebuilts/clang/host/linux-x86/clang-r450784e/bin:$tree/kernel_platform/prebuilts/kernel-build-tools/linux-x86/bin:$PATH"
python3 "$here/verify-module-inputs.py"
mkdir -p "$output/kernel" "$output/module"
cp "$here/build-inputs/kernel.config" "$output/kernel/.config"
cp "$here/build-inputs/abi_symbollist.raw" "$output/kernel/abi_symbollist.raw"
make -C "$source" O="$output/kernel" ARCH=arm64 LLVM=1 LLVM_IAS=1 LOCALVERSION=-android13-8 -j2 olddefconfig modules_prepare
cp "$here/build-inputs/Module.symvers" "$output/kernel/Module.symvers"
cp "$here/hid-nanosic-capslock.c" "$here/Makefile" "$output/module/"
make -C "$source" O="$output/kernel" M="$output/module" ARCH=arm64 LLVM=1 LLVM_IAS=1 LOCALVERSION=-android13-8 -j2 modules
python3 "$here/verify-built-module.py" "$output/module/hid-nanosic-capslock.ko"
printf 'Built %s\n' "$output/module/hid-nanosic-capslock.ko"
printf 'Compare ABI and load compatibility before replacing an installed module.\n'
