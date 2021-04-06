DOCKER_TAG := juampe/cardano
CARDANO_VERSION := 1.25.1
UNAME_N := $(shell uname -m)
all:
	docker build --build-arg JOBS="-j2" -t $(DOCKER_TAG):$(UNAME_N)-$(CARDANO_VERSION)  .
	docker push $(DOCKER_TAG):$(UNAME_N)-$(CARDANO_VERSION)


