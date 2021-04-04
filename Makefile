DOCKER_TAG := juampe/cardano
CARDANO_VERSION := 1.25.1
BUILDX_CACHE := --cache-from type=local,mode=max,src=$(HOME)/buildx-cache --cache-to type=local,mode=max,dest=$(HOME)/buildx-cache
all:
	mkdir -p $(HOME)/buildx-cache
	docker buildx build $(BUILDX_CACHE) --platform linux/arm64/v8,linux/amd64 --build-arg JOBS="-j12" -t $(DOCKER_TAG) -t $(DOCKER_TAG):$(CARDANO_VERSION) --push .

