FROM debian:bullseye
ARG TARGETARCH

RUN apt-get -y update && apt-get -y upgrade && apt-get -y install --no-install-recommends bash curl wget git ca-certificates nix && git clone https://github.com/input-output-hk/cardano-node /cardano && cd /cardano && nix-build -A scripts.mainnet.node -o mainnet-node-local && cp mainnet-node-local /usr/local/bin/
#RUN find /cardano/dist-newstyle/build/ -type f -name "cardano-node*" -exec cp {} /usr/local/bin \; && find /cardano/dist-newstyle/build/ -type f -name "cardano-cli*" -exec cp {} /usr/local/bin \;

