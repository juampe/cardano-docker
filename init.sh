#!/bin/bash
VERSION=$(/usr/local/bin/cardano-node --version|grep cardano-node|awk '{print $2}')

echo ">> Starting cardano $VERSION docker by Juampe. Enjoy it."
#CONFIGURATION
if [ ! -e "$NODE_CONFIG" ]
then
	echo ">> Initial config..."
	mkdir -p $NODE_HOME
	cd $NODE_HOME
	mkdir -p config db sockets keys logs scripts  
	cd config
	wget -q https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/$NODE_NETWORK-config.json
	wget -q https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/$NODE_NETWORK-byron-genesis.json
	wget -q https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/$NODE_NETWORK-shelley-genesis.json
	wget -q https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/$NODE_NETWORK-alonzo-genesis.json
	wget -q https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/$NODE_NETWORK-topology.json
	#Attach new eras
	jq -s ".[0] * .[1]" /util/byron.js $NODE_NETWORK-config.json.0 > $NODE_NETWORK-config.json.0
	jq -s ".[0] * .[1]" /util/shelley.js $NODE_NETWORK-config.json.1 > $NODE_NETWORK-config.json.2
	jq -s ".[0] * .[1]" /util/alonzo.js $NODE_NETWORK-config.json.2 > $NODE_NETWORK-config.json.3
	mv $NODE_NETWORK-config.json.3 $NODE_NETWORK-config.json
	ls -al $NODE_HOME/config/*
	echo "============================="
fi

if [ "$NODE_UPDATE_TOPOLOGY" == "true" ]
then
	if [ "$NODE_RUNAS_CORE" == "true" ]
	then
		echo ">> Core no default external IOHK peers"
		NODE_PEERS=""
	else
		echo ">> Default external IOHK peers relays-new.cardano-mainnet.iohk.io:3001:2"
		NODE_PEERS="relays-new.cardano-mainnet.iohk.io:3001:2"
	fi

	if [ -n "$NODE_CUSTOM_PEERS" ]
	then
		echo ">> Add custom peers $NODE_CUSTOM_PEERS"
		NODE_PEERS="$NODE_PEERS,$NODE_CUSTOM_PEERS"
	fi

	if [ -n "$NODE_CORE" ]
	then
		echo ">> Core peer $NODE_CORE"
		NODE_PEERS="$NODE_CORE,$NODE_PEERS"
	fi

	#Sanitize peers
	NODE_PEERS=$(echo "$NODE_PEERS"|sed -e 's/,,/,/g'|sed -e 's/,$//'|sed -e 's/^,//')
	/bin/echo -n "$NODE_PEERS" | jq --slurp --raw-input --raw-output 'split(",") | map(split(":")) | map({"addr": .[0],"port": .[1]|tonumber,"valency": .[2]|tonumber}) | {"Producers": .}' > $NODE_TOPOLOGY
fi

echo ">> Resolved peers $NODE_PEERS"
	

if [ "$NODE_TOPOLOGY_PULL" == "true" ]
then
	/scripts/topologyPull.sh "$NODE_PEERS" "$NODE_TOPOLOGY_PULL_MAX"
	FINAL_PEERS=$(cat $NODE_TOPOLOGY | jq -r '.Producers|map([.addr,.port,.valency] | join(":") ) | join(",")' )
	echo ">> Topology pull from api.clio.one. Final peers:[$FINAL_PEERS]"
fi

if [ "$NODE_IP" == "" ]
then
	IF=$(/sbin/ip route |grep ^default|awk '{print $5}')
	NODE_IP=$(/sbin/ip -4 addr show dev $IF scope global|grep $IF$|awk '{print $2}'|awk -F'/' '{print $1}')
	echo ">> Set IP to $NODE_IP"
fi

#UPNP behind a upnp NAT
if [ "$NODE_UPNP" == "true" ]
then
	echo ">> Set UPnP $NODE_PORT to $NODE_IP $NODE_PORT"
	EXTIP=$(/usr/bin/upnpc -e "Cardano $VERSION" -a $NODE_IP $NODE_PORT $NODE_PORT tcp | grep ExternalIPAddress|awk '{print $3}')
fi

#Some scripts and tools to home
if [ "$NODE_SCRIPTS" == "true" ]
then
	echo ">> Set scripts to $NODE_HOME/scripts/"
	cd $NODE_HOME/scripts/
	cp -a /scripts/* .

# Install cncli
#RUN git clone https://github.com/AndrewWestberg/cncli \
#    && cd cncli \
#    && cargo install --path . --force \
#    && cncli -V \
#    && cd / && rm -rf cncli

fi

if [ -n "$NODE_PROM_LISTEN"  ]
then
	echo ">> Set prometheus listen address to $NODE_PROM_LISTEN"
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
	echo ">> Set TraceMempool in $NODE_CONFIG"
	sed -i $NODE_CONFIG -e "s/TraceMempool\": false/TraceMempool\": true/g"
else
	sed -i $NODE_CONFIG -e "s/TraceMempool\": true/TraceMempool\": false/g"
fi

if [ "$NODE_TRACE_FETCH_DECISIONS" == "true" ]
then
	echo ">> Set TraceBlockFetchDecisions in $NODE_CONFIG"
	sed -i $NODE_CONFIG -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g"
else
	sed -i $NODE_CONFIG -e "s/TraceBlockFetchDecisions\": true/TraceBlockFetchDecisions\": false/g"
fi
	
if [ "$NODE_LOW_PRIORITY" == "true" ]
then
	echo ">> Set Low Priority mode"
	NODE_BINARY="nice -n10 ionice -c2 -n5 /usr/local/bin/cardano-node"
else
	NODE_BINARY="/usr/local/bin/cardano-node"
fi


if [ "$NODE_RTS" == "false" ]
then
	NODE_RTS_OPTS=""
	#NODE_RTS="+RTS -N2 --disable-delayed-os-memory-return -I0.3 -Iw600 -A16m -F1.5 -H2500M -T -S -RTS"
	echo ">> RTS Disabled"
else
	echo ">> RTS Enabled"
	if [ "$NODE_RTS_STATS" == "true" ]
	then
		NODE_RTS_OPTS="$NODE_RTS_OPTS -S"
		echo ">> RTS Stats"
	fi 
	NODE_RTS_OPTS="+RTS $NODE_RTS_OPTS -RTS"
	echo ">> RTS Options $NODE_RTS_OPTS"
fi

#Run cardano and handle SIGINT for gracefuly shutdown
if [ "$NODE_RUNAS_CORE" == "true" ]
then
	exec $NODE_BINARY run \
	$NODE_RTS_OPTS \
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
	exec $NODE_BINARY run \
	$NODE_RTS_OPTS \
  	--database-path $NODE_HOME/db \
  	--socket-path $NODE_HOME/sockets/node.socket \
  	--config $NODE_CONFIG  \
  	--topology $NODE_TOPOLOGY \
  	--host-addr $NODE_LISTEN \
  	--port $NODE_PORT
fi