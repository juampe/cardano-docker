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
	#INITIAL_PEER=$(cat $NODE_TOPOLOGY |jq -r '.Producers[0]|[.addr,.port,.valency]|join(":")')
	NODE_PEERS="relays-new.cardano-mainnet.iohk.io:3001:2"

	if [ -n "$NODE_CUSTOM_PEERS" ]
	then
		echo ">> Custom peers $NODE_CUSTOM_PEERS"
		NODE_PEERS=$NODE_PEERS,$NODE_CUSTOM_PEERS
	fi

	if [ -n "$NODE_CORE" ]
	then
		echo ">> Core peers $NODE_CORE"
		NODE_PEERS=$NODE_CORE:1,$NODE_PEERS
	fi

	/bin/echo -n "$NODE_PEERS" | jq --slurp --raw-input --raw-output 'split(",") | map(split(":")) | map({"addr": .[0],"port": .[1]|tonumber,"valency": .[2]|tonumber}) | {"Producers": .}' > $NODE_TOPOLOGY
fi

echo ">> Resolved peers $NODE_PEERS"
	


if [ "$NODE_TOPOLOGY_PULL" == "true" ]
then
		echo ">> Topology pull from api.clio.one. Custom peers:[$NODE_PEERS]"
		/scripts/topologyPull.sh "$NODE_PEERS" "$NODE_TOPOLOGY_PULL_MAX"
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
	cd $NODE_HOME/scripts/
	cp -a /scripts/* .
fi

if [ -n "$NODE_PROM_LISTEN"  ]
then
	sed -i $NODE_CONFIG -e "s/127.0.0.1/$NODE_PROM_LISTEN/g"  
fi

#Node peer push
function peer_push(){
	while true
	do	
		sleep $((60*30))
		echo ">> Topology push to api.clio.one"
		/scripts/topologyPush.sh
		sleep $((60*30))
	done
}

if [ "$NODE_TOPOLOGY_PUSH" == "true" ]
then
	peer_push &
fi

if [ "$NODE_TRACE_MEMPOOL" == "true" ]
then
	sed -i ${NODE_CONFIG} -e "s/TraceMempool\": false/TraceMempool\": true/g"
else
	sed -i ${NODE_CONFIG} -e "s/TraceMempool\": true/TraceMempool\": false/g"
fi

if [ "$NODE_TRACE_FETCH_DECISIONS" == "true" ]
then
	sed -i ${NODE_CONFIG} -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g"
else
	sed -i ${NODE_CONFIG} -e "s/TraceBlockFetchDecisions\": true/TraceBlockFetchDecisions\": false/g"
fi
	
#Run cardano and handle SIGINT for gracefuly shutdown
if [ "$NODE_RUNAS_CORE" == "true" ]
then
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
	exec /usr/local/bin/cardano-node run \
  	--database-path $NODE_HOME/db \
  	--socket-path $NODE_HOME/sockets/node.socket \
  	--config $NODE_CONFIG  \
  	--topology $NODE_TOPOLOGY \
  	--host-addr $NODE_LISTEN \
  	--port $NODE_PORT
fi