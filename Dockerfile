ARG GHC_VERSION=8.10.2
FROM juampe/base-ghc:${GHC_VERSION} as builder

ARG TARGETARCH
ARG DEBIAN_FRONTEND="noninteractive"
ARG CABAL_VERSION=3.2.0.0
ARG GHC_VERSION=8.10.2
ARG CARDANO_VERSION=1.26.1
ARG JOBS="-j1"

# export TARGETARCH=arm64 DEBIAN_FRONTEND="noninteractive" CABAL_VERSION=3.2.0.0 GHC_VERSION=8.10.2 CARDANO_VERSION=1.25.1 JOBS="-j2"

#Libsodium library ada flavour
RUN git clone https://github.com/input-output-hk/libsodium /libsodium \
  && cd /libsodium \
  && git checkout 66f017f1 \
  && ./autogen.sh \
  && ./configure \
  && make ${JOBS} install

#Compile cardano 
RUN git clone https://github.com/input-output-hk/cardano-node.git /cardano \
  && cd /cardano \
  && git fetch --all --recurse-submodules --tags \
  && git checkout tags/${CARDANO_VERSION} \
  && ~/.cabal/bin/cabal configure -O0 -w ghc-${GHC_VERSION} \
  && /bin/echo -ne  "\npackage cardano-crypto-praos\n  flags: -external-libsodium-vrf\n" >>  cabal.project.local \
  && sed -i ~/.cabal/config -e "s/overwrite-policy:/overwrite-policy: always/g" \
  && export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" \
  && export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH" \
  && ~/.cabal/bin/cabal build ${JOBS} cardano-cli cardano-node

# Create dist file
RUN cp $(find /cardano/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli \
  && cp $(find /cardano/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node \
  && tar -cvzf /cardano.tgz /usr/local/bin/cardano* /usr/local/lib/libsodium*
#Now the final container with our cardano installed
FROM ubuntu:groovy
ARG DEBIAN_FRONTEND="noninteractive"
COPY --from=builder /cardano.tgz /
RUN apt-get -y update && apt-get -y upgrade && apt-get -y install --no-install-recommends bash curl jq miniupnpc iproute2 wget ca-certificates bc tcptraceroute netbase
RUN cd / && tar -xvzf /cardano.tgz
RUN adduser --disabled-password --gecos "cardano" --uid 1001 cardano
COPY scripts/ /scripts/

#Runtime variables to init.sh
ENV LD_LIBRARY_PATH=/usr/local/lib \
  NODE_NETWORK="mainnet" \
  NODE_IP="" \
  NODE_LISTEN="0.0.0.0" \
  NODE_PORT="6000" \
  NODE_UPNP=false \
  NODE_RUNAS_CORE=false \
  NODE_UPDATE_TOPOLOGY=true \
  NODE_CUSTOM_PEERS="" \
  NODE_HOME="/home/cardano/cnode" \
  NODE_CONFIG="$NODE_HOME/config/mainnet-config.json" \
  NODE_TOPOLOGY="$NODE_HOME/config/mainnet-topology.json" \
  NODE_SHELLEY_KES_KEY="$NODE_HOME/keys/pool/kes.skey" \
  NODE_SHELLEY_VRF_KEY="$NODE_HOME/keys/pool/vrf.skey" \
  NODE_SHELLEY_OPERATIONAL_CERTIFICATE="$NODE_HOME/keys/pool/node.cert" \
  NODE_SCRIPTS=false

USER cardano

COPY init.sh /
STOPSIGNAL SIGINT
ENTRYPOINT [ "/init.sh" ]
