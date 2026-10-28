# SPDX-License-Identifier: Apache-2.0
# Included by build/make/core/main.mk after Android.mk discovery.
# Sheng installs a matched prebuilt kernel and modules. Keep source UAPI
# Android.bp modules available, but never register source DLKM make rules.
allowed_androidmk_files += $(filter-out \
    kernel_platform/% \
    vendor/qcom/opensource/audio-kernel/% \
    vendor/qcom/opensource/bt-kernel/% \
    vendor/qcom/opensource/camera-kernel/% \
    vendor/qcom/opensource/dataipa/% \
    vendor/qcom/opensource/datarmnet/% \
    vendor/qcom/opensource/datarmnet-ext/% \
    vendor/qcom/opensource/eva-kernel/% \
    vendor/qcom/opensource/graphics-kernel/% \
    vendor/qcom/opensource/mm-drivers/% \
    vendor/qcom/opensource/mmrm-driver/% \
    vendor/qcom/opensource/securemsm-kernel/% \
    vendor/qcom/opensource/touch-drivers/% \
    vendor/qcom/opensource/video-driver/% \
    vendor/qcom/opensource/wlan/platform/% \
    vendor/qcom/opensource/wlan/qcacld-3.0/% \
    vendor/qcom/opensource/display-drivers/% \
    ,$(file <$(OUT_DIR)/.module_paths/Android.mk.list))
