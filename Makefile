DOCKER_TAG := juampe/cardano
CARDANO_VERSION := 1.25.1
BUILDX_CACHE := --cache-from type=local,mode=max,src=$(HOME)/buildx-cache --cache-to type=local,mode=max,dest=$(HOME)/buildx-cache
UNAME_I := $(shell uname -i)
all:
	docker buildx build $(BUILDX_CACHE) --build-arg JOBS="-j2" -t $(DOCKER_TAG):$(UNAME_I)-$(CARDANO_VERSION)  .


