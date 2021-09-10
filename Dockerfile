ARG TARGETARCH
ARG UBUNTU
FROM ${UBUNTU}-${TARGETARCH} as builder

ARG TARGETARCH
ARG DEBIAN_FRONTEND="noninteractive"
ARG CABAL_VERSION=3.4.0.0
ARG GHC_VERSION=8.10.4
ARG CARDANO_VERSION=1.26.2
ARG JOBS="-j1"

# export TARGETARCH=riscv64 DEBIAN_FRONTEND="noninteractive" CABAL_VERSION=3.4.0.0 GHC_VERSION=8.10.4 CARDANO_VERSION=1.27.0 JOBS="-j1"

COPY util/ /util/
RUN /util/install-deb.sh ${TARGETARCH}
RUN /util/install-cabal.sh ${TARGETARCH} ${CABAL_VERSION}
RUN /util/install-ghc.sh ${TARGETARCH} ${GHC_VERSION}

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
  && /util/config-cardano.sh ${TARGETARCH} ${CARDANO_VERSION} \
  && /usr/local/bin/cabal update \
  && /usr/local/bin/cabal configure -O0 -w ghc-${GHC_VERSION} \
  && /bin/echo -ne  "\npackage cardano-crypto-praos\n  flags: -external-libsodium-vrf\n" >>  cabal.project.local \
  && /bin/echo -ne  "\npackage entropy\n  flags: -latomic\n  ghc-flags: -latomic\n" >>  cabal.project.local \
  && sed -i ~/.cabal/config -e "s/overwrite-policy:/overwrite-policy: always/g" 

RUN cd /cardano \
  && export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" \
  && export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH" \
  && /usr/local/bin/cabal build ${JOBS} cardano-cli cardano-node

# Create dist file
RUN cp $(find /cardano/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli \
  && cp $(find /cardano/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node \
  && tar -cvzf /cardano.tgz /usr/local/bin/cardano* /usr/local/lib/libsodium*

#Now the final container with our cardano installed
#FROM juampe/${UBUNTU}-${TARGETARCH}
FROM ${UBUNTU}-${TARGETARCH}
ARG DEBIAN_FRONTEND="noninteractive"
COPY --from=builder /cardano.tgz /
RUN apt-get -y update && apt-get -y upgrade && apt-get -y install --no-install-recommends bash curl jq miniupnpc iproute2 wget ca-certificates bc tcptraceroute netbase libnuma1 && apt-get -y clean
RUN cd / && tar -xvzf /cardano.tgz && LD_LIBRARY_PATH=/usr/local/lib cardano-cli --version && LD_LIBRARY_PATH=/usr/local/lib cardano-node --version
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
  NODE_HOME="/home/cardano/cnode" \
  NODE_CONFIG="/home/cardano/cnode/config/mainnet-config.json" \
  NODE_TOPOLOGY="/home/cardano/cnode/config/mainnet-topology.json" \
  NODE_SHELLEY_KES_KEY="/home/cardano/cnode/keys/pool/kes.skey" \
  NODE_SHELLEY_VRF_KEY="/home/cardano/cnode/keys/pool/vrf.skey" \
  NODE_SHELLEY_OPERATIONAL_CERTIFICATE="/home/cardano/cnode/keys/pool/node.cert" \
  NODE_SCRIPTS=false \
  NODE_CUSTOM_PEERS="" \
  NODE_UPDATE_TOPOLOGY=true \
  NODE_TOPOLOGY_PUSH=false \
  NODE_TOPOLOGY_PULL=false \
  NODE_TOPOLOGY_PULL_MAX=10 \
  NODE_TRACE_FETCH_DECISIONS=true \
  NODE_TRACE_MEMPOOL=false \
  NODE_PROM_LISTEN="" \
  NODE_HEALTH=false \
  NODE_HEALTH_TIMEOUT=180 \
  NODE_HEALTH_CPU_PCT_WARN=90 \
  NODE_HEALTH_CPU_PCT_KILL=95 \
  NODE_LOW_PRIORITY=false \
  NODE_RTS=false \
  NODE_RTS_STATS=false \
  NODE_RTS_OPTS="-N2 --disable-delayed-os-memory-return -I0.3 -Iw600 -A16m -F1.5 -H2500M -T"

HEALTHCHECK --interval=10m --timeout=3m --retries=3 --start-period=20m CMD /scripts/healthCheck.sh || bash -c 'kill -s 2 -1 && (sleep 60; kill -s 9 -1)'

USER cardano

COPY init.sh /
STOPSIGNAL SIGINT
ENTRYPOINT [ "/init.sh" ]
