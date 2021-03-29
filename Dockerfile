FROM ubuntu:focal as builder
ARG TARGETARCH
ARG DEBIAN_FRONTEND="noninteractive"
ARG CABAL_VERSION=3.2.0.0
ARG GHC_VERSION=8.10.2
ARG CARDANO_VERSION=1.25.1
ARG JOBS="-j1"
# export TARGETARCH=arm64 DEBIAN_FRONTEND="noninteractive" CABAL_VERSION=3.2.0.0 GHC_VERSION=8.10.2 CARDANO_VERSION=1.25.1 JOBS="-j1"

RUN sed -i -e "s/^\# deb-src/deb-src/g" /etc/apt/sources.list \
  && apt-get -y update && apt-get -y upgrade \
  && apt-get -y install --no-install-recommends apt-utils bash curl wget ca-certificates automake build-essential pkg-config \
    libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool \
    autoconf cabal-install cabal-debian ghc llvm-9 llvm-9-dev python3 libgmp-dev libncurses-dev libgmp3-dev happy alex \
    python3-sphinx texlive-xetex texlive-fonts-recommended fonts-lmodern texlive-latex-recommended texlive-latex-extra
 
#Install target ghc
RUN apt-get -y build-dep ghc \
  && git clone --recurse-submodules --tags https://gitlab.haskell.org/ghc/ghc.git /ghc \
  && cd /ghc \
  && git checkout ghc-${GHC_VERSION}-release \
  && git submodule update --init \
  && ./boot \
  && ./configure \
  && /bin/echo -ne "include mk/flavours/perf.mk\nGhcLibHcOpts+=-haddock\nHADDOCK_DOCS=NO\nBUILD_SPHINX_HTML=NO\nBUILD_SPHINX_PDF=NO\nHAS_OFD_LOCKING=NO" > mk/build.mk \
  && make ${JOBS} install

#Libsodium library ada flavour
RUN git clone https://github.com/input-output-hk/libsodium /libsodium \
  && cd /libsodium \
  && git checkout 66f017f1 \
  && ./autogen.sh \
  && ./configure \
  && make ${JOBS} install

#Install target cabal
RUN cabal update \
  && cabal install ${JOBS} cabal-install-${CABAL_VERSION} --constraint="lukko -ofd-locking" \
  && dpkg --purge cabal-install

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
  && tar -cvf /cardano.tar /usr/local/bin/cardano* /usr/local/lib/libsodium*

#Now the final container with our cardano installed
FROM ubuntu:focal
ARG DEBIAN_FRONTEND="noninteractive"
COPY --from=builder /cardano.tar /
RUN apt-get -y update && apt-get -y upgrade && apt-get -y install --no-install-recommends bash curl jq miniupnpc iproute2
RUN cd / && tar -xvf /cardano.tar
RUN adduser --disabled-password --gecos "cardano" cardano
#USER cardano

# COPY init.sh /
# ENTRYPOINT [ "/init.sh" ]
