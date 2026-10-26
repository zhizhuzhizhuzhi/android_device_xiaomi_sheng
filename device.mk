#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from xiaomi sm8550-common
$(call inherit-product, device/xiaomi/sm8550-sheng-common/common.mk)

# Inherit from the proprietary version
$(call inherit-product, vendor/xiaomi/sheng/sheng-vendor.mk)

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/audio/mixer_paths_kalama_mtp.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_kalama/mixer_paths_kalama_mtp.xml \
    $(LOCAL_PATH)/configs/audio/resourcemanager_kalama_mtp.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_kalama/resourcemanager_kalama_mtp.xml

# Overlay
PRODUCT_PACKAGES += \
    FrameworkResOverlaySheng \
    SettingsOverlaySheng \
    SettingsProviderResSheng \
    SystemUIOverlaySheng \
    WifiResSheng

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

TARGET_SCREEN_HEIGHT := 2032
TARGET_SCREEN_WIDTH := 3048
PRODUCT_COPY_FILES += frameworks/native/data/etc/tablet_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/tablet_core_hardware.xml

PRODUCT_RELEASE_CONFIG_MAPS += $(LOCAL_PATH)/build/release/release_config_map.textproto

# AOSPA installs the stock kernel through its product-copy target.
PRODUCT_COPY_FILES += device/xiaomi/sheng/kernel/prebuilt/Image:kernel

# Pair Composer/SDM with the stock display extension and downstream DRM ABI.
SOONG_CONFIG_NAMESPACES += sheng_display
SOONG_CONFIG_sheng_display += stock_stack
SOONG_CONFIG_sheng_display_stock_stack := true
PRODUCT_PACKAGES += vendor.qti.hardware.display.composer-service

# Stock THP host processing is required by the stock NT36532 touch firmware.
PRODUCT_PACKAGES += sheng-touch-report

# Original THP classifier models.
PRODUCT_COPY_FILES += \
    device/xiaomi/sheng/touch/firmware/film_model.tflite:$(TARGET_COPY_OUT_ODM)/firmware/film_model.tflite \
    device/xiaomi/sheng/touch/firmware/water_check.tflite:$(TARGET_COPY_OUT_ODM)/firmware/water_check.tflite \
    device/xiaomi/sheng/touch/firmware/glove_model.tflite:$(TARGET_COPY_OUT_ODM)/firmware/glove_model.tflite

# Settings declares this shared library; install its runtime and registration.
PRODUCT_PACKAGES += \
    qti-telephony-utils \
    qti_telephony_utils.xml

# Matched stock LCD backlight / DisplayFeature chain.
PRODUCT_PACKAGES += \
    sheng_df_vendor_xiaomi_hardware_displayfeature_1_0_service \
    sheng_df_displayfeature \
    sheng_df_libdisplayfeature \
    sheng_df_libdisplayfeatureservice \
    sheng_df_vendor_xiaomi_hardware_displayfeature_1_0_impl \
    sheng_df_displayfeature_default \
    sheng_df_libtruetone \
    sheng_df_libpaperMode \
    sheng_df_libcolortempmode \
    sheng_df_libflatmode \
    sheng_df_libsre \
    sheng_df_libdither \
    sheng_df_libhistprocess \
    sheng_df_libdisplaylog \
    sheng_df_libdisplaycount \
    sheng_df_libadaptivehdr

# LCD backlight: use the existing sysfs-aware Xiaomi Lights implementation.
PRODUCT_PACKAGES += android.hardware.light-service.xiaomi

# HWC clone brightness does not drive the physical LCD backlight on Sheng.
PRODUCT_SYSTEM_PROPERTIES += ro.display.force_lights_hal=true

# Matched Sheng stock performance backend and dlopen dependencies.
PRODUCT_PACKAGES += \
    sheng_perf_vendor_qti_hardware_perf_hal_service \
    sheng_perf_libqti_perfd \
    sheng_perf_libqti_perfd_client \
    sheng_perf_libperfconfig \
    sheng_perf_libperfgluelayer \
    sheng_perf_libqti_util \
    sheng_perf_libperfioctl \
    sheng_perf_vendor_qti_memory_pasrmanager_1_1 \
    sheng_perf_vendor_qti_memory_pasrmanager_1_0

PRODUCT_COPY_FILES += \
    device/xiaomi/sheng/performance/etc/perf/testtargetresourceconfigs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/testtargetresourceconfigs.xml \
    device/xiaomi/sheng/performance/etc/perf/avcsysnodesconfigs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/avcsysnodesconfigs.xml \
    device/xiaomi/sheng/performance/etc/perf/commonsysnodesconfigs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/commonsysnodesconfigs.xml \
    device/xiaomi/sheng/performance/etc/perf/thermalbreakboostconfig.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/thermalbreakboostconfig.xml \
    device/xiaomi/sheng/performance/etc/perf/targetresourceconfigs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/targetresourceconfigs.xml \
    device/xiaomi/sheng/performance/etc/perf/powerhint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/powerhint.xml \
    device/xiaomi/sheng/performance/etc/perf/targetavcsysnodesconfigs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/targetavcsysnodesconfigs.xml \
    device/xiaomi/sheng/performance/etc/perf/perfboostsconfig.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/perfboostsconfig.xml \
    device/xiaomi/sheng/performance/etc/perf/commonresourceconfigs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/commonresourceconfigs.xml \
    device/xiaomi/sheng/performance/etc/perf/perfconfigstore.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/perfconfigstore.xml \
    device/xiaomi/sheng/performance/etc/perf/thermal-boost.conf:$(TARGET_COPY_OUT_VENDOR)/etc/perf/thermal-boost.conf \
    device/xiaomi/sheng/performance/etc/perf/testcommonresourceconfigs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/testcommonresourceconfigs.xml \
    device/xiaomi/sheng/performance/etc/perf/targetconfig.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/targetconfig.xml \
    device/xiaomi/sheng/performance/etc/perf/perfboostselection.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/perfboostselection.xml \
    device/xiaomi/sheng/performance/etc/perf/targetsysnodesconfigs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/targetsysnodesconfigs.xml

# Tablet Settings embedding, at the original stock density (400 dpi).
PRODUCT_SYSTEM_PROPERTIES += persist.settings.large_screen_opt.enabled=true

# Process the existing vendor-stable OMAPI framework declaration with assemble_vintf.
PRODUCT_PACKAGES += sheng_omapi_framework_manifest

# Matched Sheng Dolby DAP engine and native control service.
PRODUCT_PACKAGES += sheng_dolby_hwdap sheng_dolby_dms_impl sheng_dolby_dsservice sheng_dolby_dms_service
PRODUCT_COPY_FILES += device/xiaomi/sheng/dolby/proprietary/etc/dolby/dax-default.xml:$(TARGET_COPY_OUT_VENDOR)/etc/dolby/dax-default.xml

# Secure channel: Sheng has no cellular modem; retain TrustZone support.
PRODUCT_COPY_FILES += \
    device/xiaomi/sheng/configs/security/sec_channel.rc:$(TARGET_COPY_OUT_VENDOR)/etc/sec_channel.rc

# Sheng four-channel OEM tuning takes precedence over generic vendor defaults.
PRODUCT_COPY_FILES += device/xiaomi/sheng/dolby/proprietary/odm/etc/dolby/dax-default.xml:$(TARGET_COPY_OUT_ODM)/etc/dolby/dax-default.xml
