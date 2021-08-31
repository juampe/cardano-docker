#!/bin/bash
ARCH=$1
RELEASE=$2
#BASE="https://github.com/juampe/base-ghc/raw/main"
#Backup due to LFS Github Limitations
BASE="https://iquis.com/repo"
echo "Download GHC $ARCH-$RELEASE"
case $ARCH in
	arm64)
		URL="$BASE/ghc/ghc-$RELEASE-$ARCH-ubuntu-21.04-linux.tar.xz"
	;;
	amd64) 
		URL="$BASE/ghc/ghc-$RELEASE-$ARCH-ubuntu-21.04-linux.tar.xz"
    ;;
	riscv64)
		URL="$BASE/ghc/ghc-$RELEASE-$ARCH-ubuntu-21.04-linux.tar.xz"
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
