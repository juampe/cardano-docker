#!/bin/bash
ARCH=$1
RELEASE=$2

echo "Download GHC $ARCH-$RELEASE"
URL="https://github.com/juampe/base-cabal/raw/main/repo/cabal-install-$RELEASE-$ARCH-ubuntu-21.04-bootstrapped.tar.xz"
echo "URL $URL"

wget "$URL" -O /cabal.tar.xz
tar -xf /cabal.tar.xz -C /tmp/
mv /tmp/cabal /usr/local/bin/
cd /
rm -Rf /cabal.tar.xz
/usr/local/bin/cabal --version
