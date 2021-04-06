DOCKER_TAG := juampe/cardano
CARDANO_VERSION := 1.25.1
ARCH:= $(shell docker version -f "{{.Server.Arch}}")
all:
	docker build --build-arg JOBS="-j2" --build-arg TARGETARCH=`docker version -f "{{.Server.Arch}}"` -t $(DOCKER_TAG):$(ARCH)-$(CARDANO_VERSION)  .
	docker push $(DOCKER_TAG):$(ARCH)-$(CARDANO_VERSION)

cache:
	docker build --build-arg JOBS="-j2" --build-arg TARGETARCH=$(ARCH) -t $(DOCKER_TAG):$(ARCH)-$(CARDANO_VERSION) -f Dockerfile.cache .
	docker push $(DOCKER_TAG):$(ARCH)-$(CARDANO_VERSION)


