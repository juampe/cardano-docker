#!/bin/bash
ARCH=$1
RELEASE=$2
URLBASE="https://downloads.haskell.org/~ghc/$RELEASE/ghc-$RELEASE"
echo "Download GHC $ARCH-$RELEASE"
case $ARCH in
	arm)
		URL="$URLBASE-armv7-deb10-linux.tar.xz"
	;;
	arm64)
		URL="$URLBASE-aarch64-deb10-linux.tar.xz"
	;;
	amd64) 
		URL="$URLBASE-x86_64-deb10-linux.tar.xz"
        ;;
esac
echo "URL $URL"

wget "$URL" -O /ghc.tar.xz
tar -xf /ghc.tar.xz -C /
cd /ghc-$RELEASE/
./configure
make install
cd /
rm -Rf /ghc.tar.xz /ghc-$RELEASE
/usr/local/bin/ghc --version