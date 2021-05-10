.PHONY : manifest cache build all
DOCKER_TAG := juampe/cardano
#CARDANO_VERSION := $(shell curl -s https://api.github.com/repos/input-output-hk/cardano-node/releases/latest | jq -r ".tag_name")
CARDANO_VERSION:= 1.26.2
RELEASE_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-new
ARCH:= $(shell docker version -f "{{.Server.Arch}}")
ARCHS:= amd64 arm64 riscv64
JOBS:= "-j2"

all: local-build local-manifest

show:
	@echo $(DOCKER_TAG):$(ARCH)-$(CARDANO_VERSION)

local-build:
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
	docker build --build-arg JOBS="-j2" --build-arg TARGETARCH=$(ARCH) --build-arg CARDANO_VERSION=$(CARDANO_VERSION) -t $(ARCH_TAG) -f Dockerfile .

cache: local-cache local-manifest

local-cache: 
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
	docker build --build-arg JOBS="-j2" --build-arg TARGETARCH=$(ARCH) --build-arg CARDANO_VERSION=$(CARDANO_VERSION) -t $(ARCH_TAG) -f Dockerfile.cache .
#	docker push $(ARCH_TAG)

local-push:
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
	docker push $(ARCH_TAG)

local-manifest: local-push
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
	docker pull $(ARCH_TAG)
	docker manifest create $(ARCH_TAG) --amend $(ARCH_TAG)
	docker manifest annotate --arch $(ARCH) $(ARCH_TAG) $(ARCH_TAG)
	docker manifest push $(ARCH_TAG)

cache-%64:
	$(eval ARCH := $(subst cache-,,$@))
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
	@echo "Build cache $(ARCH_TAG)"
	docker build --build-arg JOBS=$(JOBS) --build-arg TARGETARCH=$(ARCH) --build-arg CARDANO_VERSION=$(CARDANO_VERSION) -t $(ARCH_TAG) -f Dockerfile.cache .
	
publish: $(addprefix cache-, $(ARCHS)) manifest

push-%64:
	$(eval ARCH := $(subst push-,,$@))
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
	@echo "Push $(ARCH_TAG)"
	docker push $(ARCH_TAG)

push: $(addprefix push-, $(ARCHS))

manifest-%64:
	$(eval ARCH := $(subst manifest-,,$@))
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
	@echo "Publish $(ARCH_TAG)"
#	docker pull $(ARCH_TAG)
#	docker manifest rm $(ARCH_TAG)
#	docker manifest create $(ARCH_TAG) --amend $(ARCH_TAG)
	docker manifest annotate --arch $(ARCH) $(RELEASE_TAG) $(ARCH_TAG)
	docker manifest push $(ARCH_TAG)

amend-%64:
	$(eval ARCH := $(subst amend-,,$@))
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
	$(eval AMEND := $(AMEND) --amend $(ARCH_TAG))
	@echo "Amend $(ARCH_TAG)"

manifest-base: $(addprefix amend-,$(ARCHS))
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-new)
	@echo "Publish base release $(RELEASE_TAG)"
	docker manifest create $(RELEASE_TAG) $(AMEND)
	docker manifest push $(RELEASE_TAG)

manifest: push manifest-base $(addprefix manifest-,$(ARCHS))
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-new)
	@echo "Publish update $(RELEASE_TAG)"
	docker manifest push $(RELEASE_TAG)
