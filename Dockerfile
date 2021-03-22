FROM debian:bullseye as builder
ARG TARGETARCH
ARG DEBIAN_FRONTEND="noninteractive"
ARG CABAL_VERSION=3.2.0.0
ARG GHC_VERSION=8.10.4
ARG CARDANO_VERSION=1.25.1

#Access to ghc 8.10.4 in experimental branch
RUN /bin/echo -ne "deb http://deb.debian.org/debian/ experimental main\ndeb-src http://deb.debian.org/debian/ experimental main" > /etc/apt/sources.list.d/experimental.list && /bin/echo -ne "Package: *\nPin: release a=experimental\nPin-Priority: 1" > /etc/apt/preferences.d/experimental.pref && apt-get -y update

RUN apt-get -y upgrade && apt-get -y install --no-install-recommends apt-utils bash curl wget ca-certificates automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf iproute2 miniupnpc cabal-install cabal-debian ghc
#libllvm-11-ocaml-dev libllvm11 llvm-11 llvm-11-dev llvm-11-doc llvm-11-examples llvm-11-runtime && apt-get build-dep ghc
#ghc/experimental
#cabal 3.4.0.0.0 cabal-install-3.2.0.0 cabal install 
RUN cabal update && cabal install cabal-install-${CABAL_VERSION} --constraint="lukko -ofd-locking"
#RUN ~/.cabal/bin/cabal update && ~/.cabal/bin/cabal install  ghc-8.10.2 --constraint="lukko -ofd-locking"
#RUN ~/.cabal/bin/cabal v2-install alex happy --constraint="lukko -ofd-locking"
RUN  apt-get install --download-only ghc/experimental && dpkg -x /var/cache/apt/archives/ghc_*.deb /
#RUN git clone --recurse-submodules --tags https://gitlab.haskell.org/ghc/ghc.git /ghc && cd /ghc && git checkout ghc-${CABAL_VERSION}-release && ./boot && ALEX=~/.cabal/bin/alex HAPPY=~/.cabal/bin/happy ./configure --with-intree-gmp && hadrian/build.sh -j binary-dist
# #Libsodium library ada flavour
RUN git clone https://github.com/input-output-hk/libsodium /libsodium && cd /libsodium && git checkout 66f017f1 && ./autogen.sh && ./configure && make && make install

# #Compile cardano
# RUN git clone https://github.com/input-output-hk/cardano-node.git /cardano && cd /cardano && git fetch --all --recurse-submodules --tags && git checkout tags/${CARDANO_VERSION}
# RUN cd /cardano && ~/.cabal/bin/cabal configure -O0 -w ghc-${GHC_VERSION} 
# #/bin/echo -ne "\nconstraints:\n  lukko -ofd-locking" >>  cabal.project 
# RUN cd /cardano && /bin/echo -ne  "\npackage cardano-crypto-praos\n  flags: -external-libsodium-vrf\n" >>  cabal.project.local && sed -i ~/.cabal/config -e "s/overwrite-policy:/overwrite-policy: always/g" 
# RUN cd /cardano && export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" && export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH" && ~/.cabal/bin/cabal build -j1 -v3 cardano-cli cardano-node
# #Create dist file
# RUN sudo cp $(find /cardano/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli && sudo cp $(find /cardano/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node && tar -cvf /cardano.tar /usr/local/bin/cardano* /sur/local/lib/libsodium*

# FROM debian:sid
# ARG DEBIAN_FRONTEND="noninteractive"
# COPY --from=builder /cardano.tar /
# RUN apt-get -y update && apt-get -y upgrade && apt-get -y install --no-install-recommends bash curl jq
# RUN cd / && tar -xvf /cardano.tar
# #RUN adduser --disabled-password --gecos "cardano" cardano && usermod -aG sudo cardano
# #USER cardano

# #COPY init.sh /
# #ENTRYPOINT [ "/init.sh" ]
