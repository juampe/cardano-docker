all:
	docker build . --build-arg TARGETARCH=`docker version -f "{{.Server.Arch}}"` --build-arg JOBS="-j2" -t juampe/cardano
	#docker buildx build --platform linux/arm/v7 --build-arg JOBS="-j2" -t juampe/cardano:1.25.1 .
