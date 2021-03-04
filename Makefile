all:
	docker build . --build-arg TARGETARCH=`docker version -f "{{.Server.Arch}}"` -t juampe/cardano
