.PHONY : manifest cache build all
DOCKER_TAG := juampe/cardano
CARDANO_VERSION := 1.26.2
ARCH:= $(shell docker version -f "{{.Server.Arch}}")
all: build

build:
	docker build --build-arg JOBS="-j2" --build-arg TARGETARCH=$(ARCH) -t $(DOCKER_TAG):$(ARCH)-$(CARDANO_VERSION) -f Dockerfile .
	docker push $(DOCKER_TAG):$(ARCH)-$(CARDANO_VERSION)

cache: build-cache

build-cache:
	docker build --build-arg JOBS="-j2" --build-arg TARGETARCH=$(ARCH) -t $(DOCKER_TAG):$(ARCH)-$(CARDANO_VERSION) -f Dockerfile.cache .
	docker push $(DOCKER_TAG):$(ARCH)-$(CARDANO_VERSION)

manifest:
	docker manifest rm $(DOCKER_TAG)
	docker manifest create $(DOCKER_TAG) --amend $(DOCKER_TAG):arm64-$(CARDANO_VERSION) --amend $(DOCKER_TAG):amd64-$(CARDANO_VERSION)
	docker manifest push $(DOCKER_TAG)
	docker manifest create $(DOCKER_TAG):$(CARDANO_VERSION) --amend $(DOCKER_TAG):arm64-$(CARDANO_VERSION) --amend $(DOCKER_TAG):amd64-$(CARDANO_VERSION)
	docker manifest push $(DOCKER_TAG):$(CARDANO_VERSION)