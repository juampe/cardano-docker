.PHONY : manifest cache build all
DOCKER_TAG := juampe/cardano
#CARDANO_VERSION := $(shell curl -s https://api.github.com/repos/input-output-hk/cardano-node/releases/latest | jq -r ".tag_name")
CARDANO_VERSION:= 1.26.2
ARCH:= $(shell docker version -f "{{.Server.Arch}}")
ARCHS:= amd64 arm64 riscv64
JOBS:= "-j2"
all: build

show:
	echo $(DOCKER_TAG):$(ARCH)-$(CARDANO_VERSION)

build:
	docker build --build-arg JOBS="-j2" --build-arg TARGETARCH=$(ARCH) --build-arg CARDANO_VERSION=$(CARDANO_VERSION) -t $(DOCKER_TAG):$(ARCH)-$(CARDANO_VERSION) -f Dockerfile .
	docker push $(DOCKER_TAG):$(ARCH)-$(CARDANO_VERSION)

#cache: $(addprefix manifest-, $(ARCHS))

cache: 
	docker build --build-arg JOBS="-j2" --build-arg TARGETARCH=$(ARCH) --build-arg CARDANO_VERSION=$(CARDANO_VERSION) -t $(DOCKER_TAG):$(ARCH)-$(CARDANO_VERSION) -f Dockerfile.cache .
	docker push $(DOCKER_TAG):$(ARCH)-$(CARDANO_VERSION)

manifest2:
	docker manifest create $(DOCKER_TAG):$(CARDANO_VERSION) --amend $(DOCKER_TAG):arm64-$(CARDANO_VERSION) --amend $(DOCKER_TAG):amd64-$(CARDANO_VERSION)
	docker manifest push $(DOCKER_TAG):$(CARDANO_VERSION)
	docker manifest rm $(DOCKER_TAG)
	docker manifest create $(DOCKER_TAG) --amend $(DOCKER_TAG):arm64-$(CARDANO_VERSION) --amend $(DOCKER_TAG):amd64-$(CARDANO_VERSION)
	docker manifest push $(DOCKER_TAG)
	
cache-%64:
	$(eval ARCH := $(subst cache-,,$@))
	$(eval CNAME := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
	docker build --build-arg JOBS=$(JOBS) --build-arg TARGETARCH=$(ARCH) --build-arg CARDANO_VERSION=$(CARDANO_VERSION) -t $(CNAME) -f Dockerfile.cache .
	@echo "Build cache $(CNAME)"

push-%64:
	$(eval ARCH := $(subst push-,,$@))
	$(eval CNAME := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
	@echo "Push $(CNAME)"

push: $(addprefix push-, $(ARCHS))

manifest-%64:
	$(eval ARCH := $(subst manifest-,,$@))
	$(eval CNAME := $(DOCKER_TAG):$(CARDANO_VERSION)-$(ARCH))
	$(eval AMEND := $(AMEND) --amend $(CNAME))
	@echo "Publish $(CNAME)"
	echo docker pull $(CNAME)
	echo docker manifest create $(CNAME) --amend $(CNAME)
	echo docker manifest annotate --arch $(ARCH) $(CNAME) $(CNAME)
	echo docker manifest push $(CNAME)

manifest: push $(addprefix manifest-, $(ARCHS))
	$(eval CNAME := $(DOCKER_TAG):$(CARDANO_VERSION))
	@echo "Publish $(CNAME)"
	@echo docker manifest create $(CNAME) $(AMEND)
	@echo docker manifest push $(CNAME)
