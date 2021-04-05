DOCKER_TAG := juampe/cardano
CARDANO_VERSION := 1.25.1
UNAME_I := $(shell uname -i)
all:
	docker build --build-arg JOBS="-j2" -t $(DOCKER_TAG):$(UNAME_I)-$(CARDANO_VERSION)  .


