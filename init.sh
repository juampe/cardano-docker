#!/bin/bash


VERSION=$(/usr/local/bin/cardano-node --version|grep cardano-node|awk '{print $2}')

#CONFIGURATION
if [ ! -e "$NODE_CONFIG" ]
then
	echo "Initial config..."
	mkdir -p $NODE_HOME
	cd $NODE_HOME
	mkdir -p config db sockets keys logs scripts  
	cd config
	wget -q https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/$NODE_NETWORK-config.json
	wget -q https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/$NODE_NETWORK-byron-genesis.json
	wget -q https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/$NODE_NETWORK-shelley-genesis.json
	wget -q https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/$NODE_NETWORK-topology.json
	ls -al $NODE_HOME/config/*
	echo "============================="
fi

if [ "$NODE_UPDATE_TOPOLOGY" == "true" ]
then
	if [ -n "$NODE_CUSTOM_PEERS" ]
	then
		INITIAL_PEERS=$(cat $NODE_TOPOLOGY |jq -r '.Producers[0]|[.addr,.port,.valency]|join(":")')
		if [ -z "$NODE_CUSTOM_PEERS" ]
		then
			NODE_CUSTOM_PEERS=$INITIAL_PEERS
		else
			NODE_CUSTOM_PEERS=$INITIAL_PEERS,$NODE_CUSTOM_PEERS
		fi		
		/bin/echo -n "$NODE_CUSTOM_PEERS" | jq --slurp --raw-input --raw-output 'split(",") | map(split(":")) | map({"addr": .[0],"port": .[1]|tonumber,"valency": .[2]|tonumber}) | {"Producers": .}' > $NODE_TOPOLOGY
	fi
fi

if [ "$NODE_IP" == "" ]
then
	IF=$(/sbin/ip route |grep ^default|awk '{print $5}')
	NODE_IP=$(/sbin/ip -4 addr show dev $IF scope global|grep inet|awk '{print $2}'|awk -F'/' '{print $1}')
fi

#UPNP behind a upnp NAT
if [ "$NODE_UPNP" == "true" ]
then
	EXTIP=$(/usr/bin/upnpc -e "Cardano $VERSION" -a $NODE_IP $NODE_PORT $NODE_PORT tcp | grep ExternalIPAddress|awk '{print $3}')
fi

#Some scripts and tools
if [ "$NODE_SCRIPTS" == "true" ]
then
	cd /home/cardano/cnode/scripts
	if [ ! -e "gLiveView.sh" ]
	then
		curl -s -o gLiveView.sh https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
		curl -s -o env https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env
		sed -i env  -e "s/\#CONFIG=\"\${CNODE_HOME}\/files\/config.json\"/CONFIG=\"\${NODE_HOME}\/config\/mainnet-config.json\"/g" \
    	-e "s/\#SOCKET=\"\${CNODE_HOME}\/sockets\/node0.socket\"/SOCKET=\"\${NODE_HOME}\/sockets\/node.socket\"/g"
		chmod 755 gLiveView.sh
	fi
fi


#Run cardano and handle SIGINT for gracefuly shutdown
if [ "$NODE_BLOCK_PRODUCER" == "true" ]
then
    sed -i ${NODE_CONFIG}-config.json -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g"
	exec /usr/local/bin/cardano-node run \
  	--database-path $NODE_HOME/db \
  	--socket-path $NODE_HOME/sockets/node.socket \
  	--config $NODE_CONFIG  \
  	--topology $NODE_TOPOLOGY \
  	--host-addr $NODE_LISTEN \
  	--port $NODE_PORT \
	--shelley-kes-key $NODE_SHELLEY_KES_KEY \
	--shelley-vrf-key $NODE_SHELLEY_VRF_KEY \
	--shelley-operational-certificate $NODE_SHELLEY_OPERATIONAL_CERTIFICATE
else
	sed -i ${NODE_CONFIG}-config.json -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": false/g"
	exec /usr/local/bin/cardano-node run \
  	--database-path $NODE_HOME/db \
  	--socket-path $NODE_HOME/sockets/node.socket \
  	--config $NODE_CONFIG  \
  	--topology $NODE_TOPOLOGY \
  	--host-addr $NODE_LISTEN \
  	--port $NODE_PORT
fi