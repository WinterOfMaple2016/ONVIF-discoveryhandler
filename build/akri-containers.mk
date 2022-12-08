# Akri container defines
include build/akri-rust-containers.mk

#
# Functions for building Agent with or without Discovery Handlers
#
# Build the Agent without any Discovery Handlers embedded
define agent_build_slim
	CARGO_INCREMENTAL=$(CARGO_INCREMENTAL) PKG_CONFIG_ALLOW_CROSS=1 cross build $(if $(BUILD_RELEASE_FLAG), --release) --target=$(1) --manifest-path agent/Cargo.toml
endef

# Build the Agent with features that embed Discovery Handlers and rename the executable in case subsequently
# building a slim Agent
define agent_build_with_features
	CARGO_INCREMENTAL=$(CARGO_INCREMENTAL) PKG_CONFIG_ALLOW_CROSS=1 cross build $(if $(BUILD_RELEASE_FLAG), --release) --target=$(1) --manifest-path agent/Cargo.toml \
	--features "${AGENT_FEATURES}"
	mv target/$(1)/$(if $(BUILD_RELEASE_FLAG),release,debug)/agent target/$(1)/$(if $(BUILD_RELEASE_FLAG),release,debug)/${FULL_AGENT_EXECUTABLE_NAME}
endef

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
#	 To make an agent with embedded discovery handlers (on all platforms): `FULL_AGENT_EXECUTABLE_NAME=agent AGENT_FEATURES="onvif-feat" make akri-agent` 
#	 To make a slim agent without any embedded discovery handlers: `BUILD_SLIM_AGENT=1 make akri-agent`
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
ifeq (1, $(BUILD_SLIM_AGENT))
	$(call agent_build_slim,$(AMD64_TARGET))
endif
endif
akri-cross-build-arm32: 
ifeq (1, $(BUILD_ARM32))
	CARGO_INCREMENTAL=$(CARGO_INCREMENTAL) PKG_CONFIG_ALLOW_CROSS=1 cross build $(if $(BUILD_RELEASE_FLAG), --release) --target=$(ARM32V7_TARGET) --workspace --exclude agent $(foreach package,$(wordlist 1, 100, $(PACKAGES_TO_EXCLUDE)),--exclude $(package))
ifneq ($(AGENT_FEATURES),)
	$(call agent_build_with_features,$(ARM32V7_TARGET))
endif
ifeq (1, $(BUILD_SLIM_AGENT))
	$(call agent_build_slim,$(ARM32V7_TARGET))
endif
endif
akri-cross-build-arm64:
ifeq (1, ${BUILD_ARM64})
	CARGO_INCREMENTAL=$(CARGO_INCREMENTAL) PKG_CONFIG_ALLOW_CROSS=1 cross build $(if $(BUILD_RELEASE_FLAG), --release) --target=$(ARM64V8_TARGET) --workspace --exclude agent $(foreach package,$(wordlist 1, 100, $(PACKAGES_TO_EXCLUDE)),--exclude $(package))
ifneq ($(AGENT_FEATURES),)
	$(call agent_build_with_features,$(ARM64V8_TARGET))
endif
ifeq (1, $(BUILD_SLIM_AGENT))
	$(call agent_build_slim,$(ARM64V8_TARGET))
endif
endif

# Rust targets
$(eval $(call add_rust_targets,onvif-discovery,onvif-discovery))



