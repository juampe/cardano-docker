#!/bin/bash
export TARGETARCH=arm64 DEBIAN_FRONTEND="noninteractive" CABAL_VERSION=3.2.0.0 GHC_VERSION=8.10.2 CARDANO_VERSION=1.25.1 JOBS="-j1"
sed -i -e "s/^\# deb-src/deb-src/g" /etc/apt/sources.list && apt-get -y update && apt-get -y upgrade && apt-get -y install --no-install-recommends apt-utils bash curl wget ca-certificates automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf iproute2 miniupnpc cabal-install cabal-debian ghc llvm-9 llvm-9-dev python3 libgmp-dev libncurses-dev libgmp3-dev haskell-stack happy alex
cabal update && cabal install ${JOBS} cabal-install-${CABAL_VERSION} --constraint="lukko -ofd-locking" && dpkg --purge cabal-install
apt-get -y build-dep ghc &&  ~/.cabal/bin/cabal user-config update && ~/.cabal/bin/cabal v2-install ${JOBS} alex happy --constraint="lukko -ofd-locking" && git clone --recurse-submodules --tags https://gitlab.haskell.org/ghc/ghc.git /ghc && cd /ghc && git checkout ghc-${GHC_VERSION}-release && git submodule update --init && ./boot && ALEX=~/.cabal/bin/alex HAPPY=~/.cabal/bin/happy ./configure && PATH="~/.cabal/bin/:$PATH" hadrian/build.sh ${JOBS} binary-dist
&& PATH="~/.cabal/bin/:$PATH" make ${JOBS} install


git clone https://salsa.debian.org/haskell-team/DHG_packages.git /debghc &&  cp -r /debghc/p/ghc/debian .
# && /bin/echo -ne "BuildFlavour = quick\n" >  mk/build.mk 
# && cp ./utils/hsc2hs/data/template-hsc.h ./utils/hsc2hs/template-hsc.h  


git clone https://github.com/input-output-hk/libsodium /libsodium && cd /libsodium && git checkout 66f017f1 && ./autogen.sh && ./configure && make ${JOBS} && make ${JOBS} install
git clone https://github.com/input-output-hk/cardano-node.git /cardano && cd /cardano && git fetch --all --recurse-submodules --tags && git checkout tags/${CARDANO_VERSION}
~/.cabal/bin/cabal configure -O0 -w ghc-${GHC_VERSION} 
/bin/echo -ne  "\npackage cardano-crypto-praos\n  flags: -external-libsodium-vrf\n" >>  cabal.project.local && sed -i ~/.cabal/config -e "s/overwrite-policy:/overwrite-policy: always/g" 
LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH" ~/.cabal/bin/cabal build ${JOBS} cardano-cli cardano-node
cp $(find /cardano/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli && cp $(find /cardano/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node && tar -cvf /cardano.tar /usr/local/bin/cardano* /usr/local/lib/libsodium*



#Cleaner build

exit 0
export TARGETARCH=arm64 DEBIAN_FRONTEND="noninteractive" CABAL_VERSION=3.2.0.0 GHC_VERSION=8.10.2 CARDANO_VERSION=1.25.1 JOBS="-j2"
sed -i -e "s/^\# deb-src/deb-src/g" /etc/apt/sources.list && apt-get -y update && apt-get -y upgrade && apt-get -y install --no-install-recommends apt-utils bash curl wget ca-certificates automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf iproute2 miniupnpc cabal-install cabal-debian ghc haskell-stack happy alex llvm-9 llvm-9-dev python3 libgmp-dev libncurses-dev libgmp3-dev 
cabal update && apt-get -y build-dep ghc &&  git clone --recurse-submodules --tags https://gitlab.haskell.org/ghc/ghc.git /ghc && cd /ghc && git checkout ghc-${GHC_VERSION}-release && git submodule update --init && ./boot 
&& ALEX=~/.cabal/bin/alex HAPPY=~/.cabal/bin/happy ./configure && PATH="~/.cabal/bin/:$PATH" hadrian/build.sh ${JOBS} binary-dist
&& PATH="~/.cabal/bin/:$PATH" make ${JOBS} install
&& cabal install ${JOBS} cabal-install-${CABAL_VERSION} --constraint="lukko -ofd-locking" && dpkg --purge cabal-install


exit 0
export TARGETARCH=arm64 DEBIAN_FRONTEND="noninteractive" CABAL_VERSION=3.2.0.0 GHC_VERSION=8.10.2 CARDANO_VERSION=1.25.1 JOBS="-j2"
sed -i -e "s/^\# deb-src/deb-src/g" /etc/apt/sources.list && apt-get -y update && apt-get -y upgrade && apt-get -y install --no-install-recommends apt-utils bash curl wget ca-certificates automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf iproute2 miniupnpc cabal-install cabal-debian ghc haskell-stack happy alex llvm-9 llvm-9-dev python3 libgmp-dev libncurses-dev libgmp3-dev python3-sphinx texlive-xetex texlive-fonts-recommended fonts-lmodern texlive-latex-recommended texlive-latex-extra && apt-get -y build-dep ghc
&& git clone --recurse-submodules --tags https://gitlab.haskell.org/ghc/ghc.git /ghc && cd /ghc && git checkout ghc-${GHC_VERSION}-release && git submodule update --init && ./boot && ./configure 
&& /bin/echo -ne "include mk/flavours/perf.mk\nGhcLibHcOpts+=-haddock\nHADDOCK_DOCS=NO\nBUILD_SPHINX_HTML=NO\nBUILD_SPHINX_PDF=NO\nHAS_OFD_LOCKING=NO" > mk/build.mk \

&& make ${JOBS} 
&& make install-strip
&& make binary-dist
#&& mkdir -p libraries/dist-haddock/ && touch libraries/dist-haddock/dummy.txt