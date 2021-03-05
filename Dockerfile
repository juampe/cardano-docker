FROM debian:bullseye 
ARG TARGETARCH
ARG DEBIAN_FRONTEND="noninteractive"

#Access to ghc 8.10.4 in experimental branch
RUN /bin/echo -ne "deb http://deb.debian.org/debian/ experimental main\ndeb-src http://deb.debian.org/debian/ experimental main" > /etc/apt/sources.list.d/experimental.list && /bin/echo -ne "Package: *\nPin: release a=experimental\nPin-Priority: 1" > /etc/apt/preferences.d/experimental.pref

RUN apt-get -y update && apt-get -y upgrade && apt-get -y install --no-install-recommends bash curl wget ca-certificates automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf miniupnpc cabal-install cabal-debian ghc/experimental libsodium-dev 
RUN cabal update && cabal install --jobs=2 cabal-install 

#RUN git clone https://github.com/input-output-hk/libsodium /libsodium && cd /libsodium && git checkout 66f017f1 && ./autogen.sh && ./configure --prefix=/ && make && make install

#Access to 
RUN git clone https://github.com/input-output-hk/cardano-node.git /cardano && cd /cardano && git fetch --all --recurse-submodules --tags && git checkout tags/1.25.1 
RUN cd /cardano && ~/.cabal/bin/cabal configure --with-compiler=ghc-8.10.4 && /bin/echo -ne  "\npackage cardano-crypto-praos\n  flags: -external-libsodium-vrf\n" >>  cabal.project.local 
RUN cd /cardano && ~/.cabal/bin/cabal build --jobs=2 all && find /cardano/dist-newstyle/build/ -type f -name "cardano-node*" -exec cp {} /usr/local/bin/ \; && find /cardano/dist-newstyle/build/ -type f -name "cardano-cli*" -exec cp {} /usr/local/bin/ \; 
#RUN cd / && rm -R /cardano /libsodium && apt-get -y clean && apt-get -y remove --purge automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++


#COPY init.sh /
#ENTRYPOINT [ "/init.sh" ]
