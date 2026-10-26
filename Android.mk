# SPDX-License-Identifier: Apache-2.0
# Bridge extract-utils firmware entries to the standard AOSP radio rule.
# Keep the pinned firmware hashes enforced during Make parsing.
ifeq ($(TARGET_DEVICE),sheng)
ifndef add-radio-file-sha1-checked
define add-radio-file-sha1-checked
$(if $(filter $(2),$(firstword $(shell sha1sum $(LOCAL_PATH)/$(1) 2>/dev/null))),$(call add-radio-file,$(1)),$(error Missing firmware or SHA-1 mismatch: $(LOCAL_PATH)/$(1)))
endef
endif
endif
