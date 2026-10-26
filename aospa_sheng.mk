#
# SPDX-FileCopyrightText: Paranoid Android
# SPDX-License-Identifier: Apache-2.0
#

ifeq (aospa_sheng,$(TARGET_PRODUCT))

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)

# Wi-Fi tablet. Set before inheriting AOSPA.
TARGET_NO_TELEPHONY := true
TARGET_IS_TABLET := true
# No GNSS HAL on this Wi-Fi tablet; keep the common location support libraries.
PRODUCT_SOURCE_ROOT_DIRS += -hardware/qcom/gps/android/aidl-impl
PRODUCT_CHARACTERISTICS := tablet,nosdcard

# Use the matched stock kernel payload and modules.
TARGET_USES_KERNEL_PLATFORM := false
TARGET_KERNEL_DLKM_DISABLE := true
TARGET_QTI_SKIP_COMMON_VENDOR_PREBUILTS := true
TARGET_KERNEL_DLKM_AUDIO_OVERRIDE := false
TARGET_KERNEL_DLKM_CAMERA_OVERRIDE := false
TARGET_KERNEL_DLKM_DATAIPA_OVERRIDE := false
TARGET_KERNEL_DLKM_DATARMNETEXT_OVERRIDE := false
TARGET_KERNEL_DLKM_DATARMNET_OVERRIDE := false
TARGET_KERNEL_DLKM_DISPLAY_OVERRIDE := false
TARGET_KERNEL_DLKM_MM_DRV_OVERRIDE := false
TARGET_KERNEL_DLKM_MMRM_OVERRIDE := false
TARGET_KERNEL_DLKM_SECURE_MSM_OVERRIDE := false
TARGET_KERNEL_DLKM_TOUCH_OVERRIDE := false
TARGET_KERNEL_DLKM_VIDEO_OVERRIDE := false


# Inherit from the device configuration.
$(call inherit-product, device/xiaomi/sheng/device.mk)

# Inherit from the AOSPA configuration.
$(call inherit-product, vendor/aospa/target/product/aospa-target.mk)


PRODUCT_BRAND := Xiaomi
PRODUCT_DEVICE := sheng
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_MODEL := Xiaomi Pad 6S Pro 12.4
PRODUCT_NAME := aospa_sheng

PRODUCT_BUILD_PROP_OVERRIDES += \
    DeviceProduct=sheng

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

# Boot Animation
TARGET_BOOT_ANIMATION_RES := 1440

endif
