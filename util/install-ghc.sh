#!/bin/bash
ARCH=$1
RELEASE=$2

. /etc/os-release 
BASE="https://iquis.com/repo"
URL="$BASE/ghc/ghc-$RELEASE-$ARCH-ubuntu-$VERSION_ID-linux.tar.xz"
echo "Download GHC $ARCH-$RELEASE"
echo "URL $URL"
wget "$URL" -q -O /ghc.tar.xz
tar -xf /ghc.tar.xz -C /
cd /ghc-*/
./configure
make install
cd /
rm -Rf /ghc.tar.xz /ghc-*

ghc --version

