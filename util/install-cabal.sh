#!/bin/bash
ARCH=$1
RELEASE=$2

URLBASE="https://downloads.haskell.org/~cabal/cabal-install-${RELEASE}/cabal-install-${RELEASE}"
echo "Download GHC $ARCH-$RELEASE"
case $ARCH in
	arm64)
		URL="$URLBASE-aarch64-ubuntu-18.04.tar.xz"
	;;
	amd64) 
		URL="$URLBASE-x86_64-ubuntu-16.04.tar.xz"
        ;;
esac
echo "URL $URL"

wget "$URL" -O /cabal.tar.xz
tar -xf /cabal.tar.xz -C /tmp/
mv /tmp/cabal /usr/local/bin/
cd /
rm -Rf /cabal.tar.xz
/usr/local/bin/cabal --version
