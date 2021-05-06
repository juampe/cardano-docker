.PHONY : manifest cache build all
DOCKER_TAG := juampe/cardano
CARDANO_VERSION := $(shell curl -s https://api.github.com/repos/input-output-hk/cardano-node/releases/latest | jq -r ".tag_name")
ARCH:= $(shell docker version -f "{{.Server.Arch}}")
all: build

show:
	echo $(DOCKER_TAG):$(ARCH)-$(CARDANO_VERSION)

build:
	docker build --build-arg JOBS="-j2" --build-arg TARGETARCH=$(ARCH) --build-arg CARDANO_VERSION=$(CARDANO_VERSION) -t $(DOCKER_TAG):$(ARCH)-$(CARDANO_VERSION) -f Dockerfile .
	docker push $(DOCKER_TAG):$(ARCH)-$(CARDANO_VERSION)

cache: build-cache

build-cache:
	docker build --build-arg JOBS="-j2" --build-arg TARGETARCH=$(ARCH) --build-arg CARDANO_VERSION=$(CARDANO_VERSION) -t $(DOCKER_TAG):$(ARCH)-$(CARDANO_VERSION) -f Dockerfile.cache .
	docker push $(DOCKER_TAG):$(ARCH)-$(CARDANO_VERSION)

manifest:
	docker manifest create $(DOCKER_TAG):$(CARDANO_VERSION) --amend $(DOCKER_TAG):arm64-$(CARDANO_VERSION) --amend $(DOCKER_TAG):amd64-$(CARDANO_VERSION)
	docker manifest push $(DOCKER_TAG):$(CARDANO_VERSION)
	docker manifest rm $(DOCKER_TAG)
	docker manifest create $(DOCKER_TAG) --amend $(DOCKER_TAG):arm64-$(CARDANO_VERSION) --amend $(DOCKER_TAG):amd64-$(CARDANO_VERSION)
	docker manifest push $(DOCKER_TAG)
	