#!/bin/bash
ARCH=$1
RELEASE=$2
URLBASE="https://downloads.haskell.org/~ghc/$RELEASE/ghc-$RELEASE"
echo "Download GHC $ARCH-$RELEASE"
case $ARCH in
	arm64)
		URL="$URLBASE-aarch64-deb10-linux.tar.xz"
		URL="https://github.com/juampe/base-ghc/raw/main/repo/ghc-$RELEASE-$ARCH-ubuntu-21.04-linux.tar.xz"
	;;
	amd64) 
		URL="$URLBASE-x86_64-deb10-linux.tar.xz"
		URL="https://github.com/juampe/base-ghc/raw/main/repo/ghc-$RELEASE-$ARCH-ubuntu-21.04-linux.tar.xz"
    ;;
	riscv64)
		#apt-get -y install debian-ports-archive-keyring
        #/bin/echo -ne "deb http://ftp.ports.debian.org/debian-ports experimental main\ndeb-src http://ftp.ports.debian.org/debian-ports experimental main\n"> /etc/apt/sources.list.d/experimental.list
        #/bin/echo -ne "Package: ghc\nPin: release a=experimental\nPin-Priority: 600" > /etc/apt/preferences.d/ghc.pref
        #apt-get -y update
		#apt-get -y install ghc
	;;
esac

if [ -n "$URL" ]
then
	echo "URL $URL"

	wget "$URL" -O /ghc.tar.xz
	tar -xf /ghc.tar.xz -C /
	cd /ghc-$RELEASE/
	./configure
	make install
	cd /
	rm -Rf /ghc.tar.xz /ghc-$RELEASE
fi
ghc --version
#/usr/local/bin/ghc --version
