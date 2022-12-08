# Akri container defines
include build/akri-rust-containers.mk

#
#
# INSTALL-CROSS: install cargo cross building tool:
#
#    `make install-cross`
#
#
.PHONY: install-cross
install-cross:
	cargo install cross


#
#
# AKRI: make and push the images for akri:
#
#    To make all platforms: `make akri`
#    To make specific platforms: `BUILD_AMD64=1 BUILD_ARM32=0 BUILD_ARM64=1 make akri`
#    To make single component: `make akri-[onvif|onvif-discovery]`
#    To make specific platforms: `BUILD_AMD64=1 BUILD_ARM32=0 BUILD_ARM64=1 make akri-[onvif|onvif-discovery]` 
#
.PHONY: akri
akri: akri-build akri-docker-all
akri-build: install-cross akri-cross-build
akri-docker-all: akri-docker-onvif akri-docker-onvif-discovery

akri-cross-build: akri-cross-build-amd64 akri-cross-build-arm32 akri-cross-build-arm64
akri-cross-build-amd64:
ifeq (1, $(BUILD_AMD64))
	CARGO_INCREMENTAL=$(CARGO_INCREMENTAL) PKG_CONFIG_ALLOW_CROSS=1 cross build $(if $(BUILD_RELEASE_FLAG), --release) --target=$(AMD64_TARGET) --workspace --exclude agent $(foreach package,$(wordlist 1, 100, $(PACKAGES_TO_EXCLUDE)),--exclude $(package))
ifneq ($(AGENT_FEATURES),)
	$(call agent_build_with_features,$(AMD64_TARGET))
endif
endif
akri-cross-build-arm32: 
ifeq (1, $(BUILD_ARM32))
	CARGO_INCREMENTAL=$(CARGO_INCREMENTAL) PKG_CONFIG_ALLOW_CROSS=1 cross build $(if $(BUILD_RELEASE_FLAG), --release) --target=$(ARM32V7_TARGET) --workspace --exclude agent $(foreach package,$(wordlist 1, 100, $(PACKAGES_TO_EXCLUDE)),--exclude $(package))
ifneq ($(AGENT_FEATURES),)
	$(call agent_build_with_features,$(ARM32V7_TARGET))
endif
endif
akri-cross-build-arm64:
ifeq (1, ${BUILD_ARM64})
	CARGO_INCREMENTAL=$(CARGO_INCREMENTAL) PKG_CONFIG_ALLOW_CROSS=1 cross build $(if $(BUILD_RELEASE_FLAG), --release) --target=$(ARM64V8_TARGET) --workspace --exclude agent $(foreach package,$(wordlist 1, 100, $(PACKAGES_TO_EXCLUDE)),--exclude $(package))
ifneq ($(AGENT_FEATURES),)
	$(call agent_build_with_features,$(ARM64V8_TARGET))
endif
endif

# Rust targets
$(eval $(call add_rust_targets,onvif-discovery,onvif-discovery))



