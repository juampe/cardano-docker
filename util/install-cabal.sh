#!/bin/bash
ARCH=$1
RELEASE=$2

echo "Download GHC $ARCH-$RELEASE"
. /etc/os-release 
BASE="https://iquis.com/repo"
URL="$BASE/cabal/cabal-install-$RELEASE-$ARCH-ubuntu-$VERSION_ID-bootstrapped.tar.xz"
echo "URL $URL"

wget "$URL" -q -O /cabal.tar.xz
tar -xf /cabal.tar.xz -C /tmp/
mv /tmp/cabal /usr/local/bin/
#chmod 755 /usr/local/bin/cabal
cd /
rm -Rf /cabal.tar.xz
/usr/local/bin/cabal --version
