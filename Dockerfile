FROM debian:bullseye 
ARG TARGETARCH
ARG DEBIAN_FRONTEND="noninteractive"

#Access to ghc 8.10.4 in experimental branch
RUN /bin/echo -ne "deb http://deb.debian.org/debian/ experimental main\ndeb-src http://deb.debian.org/debian/ experimental main" > /etc/apt/sources.list.d/experimental.list && /bin/echo -ne "Package: *\nPin: release a=experimental\nPin-Priority: 1" > /etc/apt/preferences.d/experimental.pref

RUN apt-get -y update && apt-get -y upgrade && apt-get -y install --no-install-recommends bash curl wget ca-certificates automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf iproute2 miniupnpc cabal-install cabal-debian ghc/experimental 
USER cardano
RUN cabal update && cabal install --jobs=1 Cabal-3.2.0.0 

#3.2.0.0
# mkdir $HOME/git 
#cd $HOME/git 
#git clone https://github.com/input-output-hk/libsodium 
#cd libsodium 
#git checkout 66f017f1 
#./autogen.sh 
#./configure 
#make -j1 
#sudo make -j1 install 
#cd 
#wget https://downloads.haskell.org/~cabal/cabal-install-3.2.0.0/cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz 
#tar -xf cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz 
#rm cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz cabal.sig 
#mkdir -p $HOME/.local/bin 
#mv cabal $HOME/.local/bin/ 
#wget https://downloads.haskell.org/ghc/8.10.2/ghc-8.10.2-x86_64-deb9-linux.tar.xz 
#tar -xf ghc-8.10.2-x86_64-deb9-linux.tar.xz 
#rm ghc-8.10.2-x86_64-deb9-linux.tar.xz 
#cd ghc-8.10.2 
#./configure 
#sudo make -j1 install 
#echo PATH="$HOME/.local/bin:$PATH" >> $HOME/.bashrc 
#echo export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" >> $HOME/.bashrc 
#echo export NODE_HOME=$HOME/cnode >> $HOME/.bashrc 
#echo export NODE_CONFIG=mainnet>> $HOME/.bashrc 
#echo export NODE_BUILD_NUM=$(curl https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html | grep -e "build" | sed 's/.*build\/\([0-9]*\)\/download.*/\1/g') >> $HOME/.bashrc 
#source $HOME/.bashrc 
#cabal update 
#cabal -V 
#ghc -V 
#cd $HOME/git 
#git clone https://github.com/input-output-hk/cardano-node.git 
#cd cardano-node 
#git fetch --all --recurse-submodules --tags 
#git checkout tags/1.25.1 
#cabal configure --jobs=1 -O0 -w ghc-8.10.2 
#echo -e "package cardano-crypto-praos\n flags: -external-libsodium-vrf" > cabal.project.local 
#sed -i $HOME/.cabal/config -e "s/overwrite-policy:/overwrite-policy: always/g" 
#rm -rf $HOME/git/cardano-node/dist-newstyle/build/x86_64-linux/ghc-8.10.2 
#cabal build --jobs=1 cardano-cli cardano-node 
#sudo cp $(find $HOME/git/cardano-node/dist-n

#Libsodium library ada flavour
#RUN git clone https://github.com/input-output-hk/libsodium /libsodium && cd /libsodium && git checkout 66f017f1 && ./autogen.sh && ./configure && make -j1 && make -j1 install

#Access to 
#RUN git clone https://github.com/input-output-hk/cardano-node.git /cardano && cd /cardano && git fetch --all --recurse-submodules --tags && git checkout tags/1.25.1 
#RUN cd /cardano && ~/.cabal/bin/cabal configure --with-compiler=ghc-8.10.4 && /bin/echo -ne  "\npackage cardano-crypto-praos\n  flags: -external-libsodium-vrf\n" >>  cabal.project.local 
#RUN cd /cardano && export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" && export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH" && ~/.cabal/bin/cabal build --jobs=2 all && find /cardano/dist-newstyle/build/ -type f -name "cardano-node*" -exec cp {} /usr/local/bin/ \; && find /cardano/dist-newstyle/build/ -type f -name "cardano-cli*" -exec cp {} /usr/local/bin/ \; 


#FROM debian:sid
#ARG DEBIAN_FRONTEND="noninteractive"
#RUN apt-get -y update && apt-get -y upgrade && apt-get -y install --no-install-recommends bash curl jq

#COPY --from=builder /tmp/${PKG_NAME}_${GUAC_VER}.deb /tmp/${PKG_NAME}_${GUAC_VER}.deb
#RUN cd / && rm -R /cardano /libsodium && apt-get -y clean && apt-get -y remove --purge automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++

#COPY init.sh /
#ENTRYPOINT [ "/init.sh" ]
