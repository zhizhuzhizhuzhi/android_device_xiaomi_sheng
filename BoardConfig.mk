#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from xiaomi sm8550-common
include device/xiaomi/sm8550-sheng-common/BoardConfigCommon.mk

# Inherit from the proprietary version
include vendor/xiaomi/sheng/BoardConfigVendor.mk

DEVICE_PATH := device/xiaomi/sheng

# Display
TARGET_SCREEN_DENSITY := 400

# Kernel modules are supplied by the verified stock payload below.

# OTA assert
TARGET_OTA_ASSERT_DEVICE := sheng

# Properties
TARGET_ODM_PROP += $(DEVICE_PATH)/properties/odm.prop
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/properties/system.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/properties/vendor.prop

# Sepolicy
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor

# Matched Sheng kernel, DTB, DTBO, and modules.
include $(DEVICE_PATH)/kernel/BoardConfigKernel.mk

