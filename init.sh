#!/bin/bash

export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"

VERSION=$(/usr/local/bin/cardano-node --version|grep cardano-node|awk '{print $2}')

#CONFIGURATION
if [ ! -e "/cardano/config/mainnet-config.json" ]
then
	echo "Initial config..."
	mkdir -p /cardano
	cd /cardano
	mkdir -p config db sockets keys logs scripts  
	cd config
	wget -q https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-config.json
	wget -q https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-byron-genesis.json
	wget -q https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-shelley-genesis.json
	wget -q https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-topology.json
	ls -al mainnet*
fi

IF=$(/sbin/ip route |grep ^default|awk '{print $5}')
IP=$(/sbin/ip -4 addr show dev br0 scope global|grep inet|awk '{print $2}'|awk -F'/' '{print $1}')
EXTIP=$(/usr/bin/upnpc -e "Cardano $VERSION" -a $IP 3000 3000 tcp | grep ExternalIPAddress|awk '{print $3}')
EXTIP=$(/usr/bin/upnpc -e "Cardano $VERSION" -a $IP 3000 3000 udp | grep ExternalIPAddress|awk '{print $3}')

/usr/local/bin/cardano-node run --database-path /cardano/db --socket-path /cardano/sockets/node.socket --config /cardano/config/mainnet-config.json  --topology /cardano/config/mainnet-topology.json --host-addr $IP --port 3000
