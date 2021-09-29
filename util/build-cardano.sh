#!/bin/bash
ARCH=$1
RELEASE=$2
JOBS=$3
echo "Build cardano $ARCH-$RELEASE"

cd /cardano 
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH" 

#x86_64 and armv8-1a implements atomic locks
case $ARCH in
	amd64|arm64) 
		/usr/local/bin/cabal build ${JOBS} cardano-cli cardano-node
    ;;
	riscv64)
		/usr/local/bin/cabal build --ghc-options='-latomic' ${JOBS} cardano-cli cardano-node
	;;
esac
