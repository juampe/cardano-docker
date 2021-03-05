FROM debian:bullseye 
ARG TARGETARCH
ARG DEBIAN_FRONTEND="noninteractive"

RUN /bin/echo -ne "deb http://deb.debian.org/debian/ experimental main\ndeb-src http://deb.debian.org/debian/ experimental main" > /etc/apt/sources.list.d/experimental.list && /bin/echo -ne "Package: *\nPin: release a=experimental\nPin-Priority: 1" > /etc/apt/preferences.d/experimental.pref

RUN apt-get -y update && apt-get -y upgrade && apt-get -y install --no-install-recommends bash curl wget ca-certificates automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf miniupnpc cabal-install cabal-debian ghc/experimental libsodium-dev && cabal update && cabal install --jobs=2 cabal-install 

RUN  export PATH="~/.cabal/bin/:$PATH" && git clone https://github.com/input-output-hk/cardano-node.git /cardano && cd /cardano && git fetch --all --recurse-submodules --tags && git checkout tags/1.25.1 && cabal configure --with-compiler=ghc-8.10.4 && cd /cardano && cabal build --jobs=2 all

#git clone https://github.com/input-output-hk/cardano-node.git /cardano && cd /cardano && git fetch --all --recurse-submodules --tags && git checkout tags/1.25.1 && cabal configure --with-compiler=ghc-8.10.4 && cd /cardano && echo "package cardano-crypto-praos" >>  cabal.project.local && echo "  flags: -external-libsodium-vrf" >>  cabal.project.local && export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" && export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH" && cabal build --jobs=2 all

#&& find /cardano/dist-newstyle/build/ -type f -name "cardano-node*" -exec cp {} /usr/local/bin \; && find /cardano/dist-newstyle/build/ -type f -name "cardano-cli*" -exec cp {} /usr/local/bin \; && 
#rm -R /cardano && apt-get -y clean && apt-get -y remove --purge automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++


#COPY init.sh /
#ENTRYPOINT [ "/init.sh" ]
