# SPDX-License-Identifier: Apache-2.0
# One matched Sheng kernel build; never fall back to the Fuxi kernel output.
SHENG_KERNEL_PATH := device/xiaomi/sheng/kernel/prebuilt
TARGET_PREBUILT_KERNEL := $(SHENG_KERNEL_PATH)/Image
TARGET_COMPILE_WITH_MSM_KERNEL := false
TARGET_USES_KERNEL_PLATFORM := false
TARGET_KERNEL_DLKM_DISABLE := true
BOARD_PREBUILT_DTBOIMAGE := $(SHENG_KERNEL_PATH)/dtbo.img
BOARD_PREBUILT_DTBIMAGE_DIR := $(SHENG_KERNEL_PATH)/dtb

BOARD_SYSTEM_KERNEL_MODULES := $(wildcard $(SHENG_KERNEL_PATH)/system_dlkm/*.ko)
BOARD_VENDOR_KERNEL_MODULES := $(wildcard $(SHENG_KERNEL_PATH)/vendor_dlkm/*.ko)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(wildcard $(SHENG_KERNEL_PATH)/vendor_ramdisk/*.ko)
BOARD_VENDOR_KERNEL_MODULES_LOAD := $(strip $(shell cat $(SHENG_KERNEL_PATH)/modules.load.vendor_dlkm 2>/dev/null))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(strip $(shell cat $(SHENG_KERNEL_PATH)/modules.load.first_stage 2>/dev/null))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(strip $(shell cat $(SHENG_KERNEL_PATH)/modules.load.recovery 2>/dev/null))
BOOT_KERNEL_MODULES := $(BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD)

# Preserve the official module autoload blocklists.
BOARD_VENDOR_KERNEL_MODULES_BLOCKLIST_FILE := $(SHENG_KERNEL_PATH)/vendor_dlkm/modules.blocklist
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_BLOCKLIST_FILE := $(SHENG_KERNEL_PATH)/vendor_ramdisk/modules.blocklist

# Preserve official module signatures.
BOARD_DO_NOT_STRIP_VENDOR_MODULES := true
BOARD_DO_NOT_STRIP_VENDOR_RAMDISK_MODULES := true
