.PHONY : manifest cache build all
ARCH:= $(shell docker version -f "{{.Server.Arch}}")
#ARCHS:= amd64 arm64 riscv64
ARCHS:= amd64 arm64
DOCKER_TAG := juampe/cardano
CARDANO_VERSION := $(shell curl -s https://api.github.com/repos/input-output-hk/cardano-node/releases/latest | jq -r ".tag_name")
#CARDANO_VERSION := 1.27.0
LATEST_TAG := $(DOCKER_TAG):latest
RELEASE_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)
ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH)
JOBS:= "-j1"

############
#Local stuff
############
all: local-build local-repo local-cache local-manifest

show:
	@echo $(ARCH_TAG)

local-build:
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
	docker build --build-arg JOBS="-j2" --build-arg TARGETARCH=$(ARCH) --build-arg CARDANO_VERSION=$(CARDANO_VERSION) -t $(ARCH_TAG) -f Dockerfile .

local-repo:
ifeq ($(shell test -s repo/cardano-$(ARCH)-$(CARDANO_VERSION).tgz && echo -n yes),yes)
	@echo "repo/cardano-$(ARCH)-$(CARDANO_VERSION).tgz already exist"
else
	docker run --entrypoint "" --rm $(ARCH_TAG) bash -c 'cat /cardano.tgz' > repo/cardano-$(ARCH)-$(CARDANO_VERSION).tgz
endif

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
	docker pull --platform linux/$(ARCH) $(ARCH_TAG)
	docker manifest create $(ARCH_TAG) --amend $(ARCH_TAG)
	docker manifest annotate --arch $(ARCH) $(ARCH_TAG) $(ARCH_TAG)
	docker manifest push $(ARCH_TAG)

################
#Multiarch stuff
################
pilepine: build repo publish

#Phase 1 pipeline
build: $(addprefix build-, $(ARCHS))
build-%64:
	$(eval ARCH := $(subst build-,,$@))
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
	@echo "Build cache $(ARCH_TAG)"
	docker build --build-arg JOBS=$(JOBS) --build-arg TARGETARCH=$(ARCH) --build-arg CARDANO_VERSION=$(CARDANO_VERSION) -t $(ARCH_TAG) -f Dockerfile .


#Parse 2 pipeline
repo: $(addprefix repo-, $(ARCHS))
repo-%64:
	$(eval ARCH := $(subst repo-,,$@))
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
ifeq ($(shell test -s repo/cardano-$(ARCH)-$(CARDANO_VERSION).tgz && echo -n yes),yes)
	@echo "repo/cardano-$(ARCH)-$(CARDANO_VERSION).tgz already exist"
else
	docker run --entrypoint "" --rm $(ARCH_TAG) bash -c 'cat /cardano.tgz' > repo/cardano-$(ARCH)-$(CARDANO_VERSION).tgz
endif

cache-%64:
	$(eval ARCH := $(subst cache-,,$@))
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
	@echo "Build cache $(ARCH_TAG)"
	docker build --build-arg JOBS=$(JOBS) --build-arg TARGETARCH=$(ARCH) --build-arg CARDANO_VERSION=$(CARDANO_VERSION) -t $(ARCH_TAG) -f Dockerfile.cache .

#Phase 2 pipeline	
publish: $(addprefix cache-, $(ARCHS)) manifest

push-%64:
	$(eval ARCH := $(subst push-,,$@))
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
	@echo "Push $(ARCH_TAG)"
	docker push $(ARCH_TAG)

push: $(addprefix push-, $(ARCHS))
	$(eval ARCH := $(subst pull-,,$@))
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
#	@echo "Push $(ARCH_TAG)"
#	docker push $(DOCKER_TAG):latest

pull-%64:
	$(eval ARCH := $(subst pull-,,$@))
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
	@echo "Pull $(ARCH_TAG)"
	docker pull --platform linux/$(ARCH) $(ARCH_TAG)

pull: $(addprefix pull-, $(ARCHS))

manifest-%64:
	$(eval ARCH := $(subst manifest-,,$@))
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
	@echo "Publish $(ARCH_TAG)"
	docker pull --platform linux/$(ARCH) $(ARCH_TAG)
#	docker rm $(ARCH_TAG)
	docker manifest create $(ARCH_TAG) --amend $(ARCH_TAG)
	docker manifest annotate --arch $(ARCH) $(RELEASE_TAG) $(ARCH_TAG)
	docker manifest annotate --arch $(ARCH) $(ARCH_TAG) $(ARCH_TAG)
	docker manifest push $(ARCH_TAG)

amend-%64:
	$(eval ARCH := $(subst amend-,,$@))
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
	$(eval AMEND := $(AMEND) --amend $(ARCH_TAG))
	@echo "Amend $(ARCH_TAG)"

manifest-clean-%64: 
	$(eval ARCH := $(subst manifest-clean-,,$@))
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
	@echo "Clear manifest $(ARCH_TAG)"
	docker manifest rm $(ARCH_TAG) || return 0 >/dev/null

manifest-clean: $(addprefix manifest-clean-,$(ARCHS))
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION))
	@echo "Clear manifest $(DOCKER_TAG):latest"
	docker manifest rm $(DOCKER_TAG):latest || return 0 >/dev/null
	
manifest-base: $(addprefix amend-,$(ARCHS))
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION))
	@echo "Publish base release $(RELEASE_TAG)"
	docker manifest create $(LATEST_TAG) $(AMEND)
	docker manifest push $(LATEST_TAG)
	docker manifest create $(RELEASE_TAG) $(AMEND)
	docker manifest push $(RELEASE_TAG)

manifest: push manifest-base $(addprefix manifest-,$(ARCHS))
	$(eval ARCH_TAG := $(DOCKER_TAG):$(CARDANO_VERSION))
	@echo "Publish update $(DOCKER_TAG)"
	docker manifest push $(LATEST_TAG)
	docker manifest push $(RELEASE_TAG)
