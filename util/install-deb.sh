#!/bin/bash
ARCH=$1

echo "Download Debs for $ARCH"
cat /etc/apt/sources.list|sed -e 's/^deb /deb-src /' >> /etc/apt/sources.list
echo "nameserver 1.1.1.1" > /etc/resolv.conf
apt-get -y update 
apt-get -y upgrade

case $ARCH in
	arm64|riscv64)
		apt-get -y install --no-install-recommends apt-utils bash curl wget ca-certificates automake build-essential pkg-config \
        libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool \
        autoconf libnuma1 libnuma-dev llvm-9 llvm-9-dev
	    ;;
	amd64) 
        apt-get -y install --no-install-recommends apt-utils bash curl wget ca-certificates automake build-essential pkg-config \
        libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool \
        autoconf
        ;;
    riscv64)
        apt-get -y install --no-install-recommends apt-utils bash curl wget ca-certificates automake build-essential pkg-config \
        libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool \
        autoconf libnuma1 libnuma-dev llvm-9 llvm-9-dev
	    ;;
esac
