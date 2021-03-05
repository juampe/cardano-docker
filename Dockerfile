FROM debian:bullseye 
ARG TARGETARCH
ARG DEBIAN_FRONTEND="noninteractive"

RUN /bin/echo -ne "deb http://deb.debian.org/debian/ experimental main\ndeb-src http://deb.debian.org/debian/ experimental main" > /etc/apt/sources.list.d/experimental.list && /bin/echo -ne "Package: *\nPin: release a=experimental\nPin-Priority: 1" > /etc/apt/preferences.d/experimental.pref

RUN apt-get -y update && apt-get -y upgrade && apt-get -y install --no-install-recommends bash curl wget ca-certificates automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf miniupnpc cabal-install cabal-debian ghc/experimental libsodium-dev && cabal update && cabal install --jobs=2 cabal-install 
RUN git clone https://github.com/input-output-hk/cardano-node.git /cardano && cd /cardano && git fetch --all --recurse-submodules --tags && git checkout tags/1.25.1 && cabal configure --with-compiler=ghc-8.10.2 && cd /cardano && echo "package cardano-crypto-praos" >>  cabal.project.local && echo "  flags: -external-libsodium-vrf" >>  cabal.project.local && export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" && export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH" && cd /cardano && cabal build --jobs=2 all

#&& find /cardano/dist-newstyle/build/ -type f -name "cardano-node*" -exec cp {} /usr/local/bin \; && find /cardano/dist-newstyle/build/ -type f -name "cardano-cli*" -exec cp {} /usr/local/bin \; && 
#rm -R /cardano && apt-get -y clean && apt-get -y remove --purge automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++


#RUN apt-get -y update && apt-get -y upgrade && apt-get -y install --no-install-recommends bash curl wget ca-certificates automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf miniupnpc &&  mkdir /src && cd /src && wget https://downloads.haskell.org/~cabal/cabal-install-3.2.0.0/cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz && tar -xf cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz && rm cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz cabal.sig && mv cabal /usr/local/bin/ && cabal update && cd /src && wget https://downloads.haskell.org/ghc/8.10.2/ghc-8.10.2-x86_64-deb9-linux.tar.xz && tar -xf ghc-8.10.2-x86_64-deb9-linux.tar.xz && rm ghc-8.10.2-x86_64-deb9-linux.tar.xz && cd ghc-8.10.2 && ./configure && make install && cd /src && git clone https://github.com/input-output-hk/libsodium && cd libsodium && git checkout 66f017f1 && ./autogen.sh && ./configure && make && make install && cd / && git clone https://github.com/input-output-hk/cardano-node.git /cardano && cd /cardano && git fetch --all --recurse-submodules --tags && git checkout tags/1.25.1 && cabal configure --with-compiler=ghc-8.10.2 && cd /cardano && echo "package cardano-crypto-praos" >>  cabal.project.local && echo "  flags: -external-libsodium-vrf" >>  cabal.project.local && export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" && export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH" && cd /cardano && cabal build all && find /cardano/dist-newstyle/build/ -type f -name "cardano-node*" -exec cp {} /usr/local/bin \; && find /cardano/dist-newstyle/build/ -type f -name "cardano-cli*" -exec cp {} /usr/local/bin \; && /bin/echo -e  'export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"\nexport PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"' > /root/.bashrc && rm -R /cardano && apt-get -y clean && apt-get -y remove --purge automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++

#HEALTHCHECK --interval=1m --timeout=10s --retries=3 --start-period=1m \
#   CMD rpcinfo filer > /dev/null || bash -c 'kill -s 15 -1 && (sleep 10; kill -s 9 -1)'

COPY init.sh /
ENTRYPOINT [ "/init.sh" ]
