#!/bin/bash
# From Guild https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node#14-configure-your-topology-files
# shellcheck disable=SC2086,SC2034
 
#USE YOUR PREFERENCES
#NODE_EXTERNAL_IP="CHANGE ME"
#NODE_EXTERNAL_IP=$(curl ifconfig.me)
#NODE_EXTERNAL_IP=$(curl icanhazip.com)
#NODE_EXTERNAL_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
NODE_EXTERNAL_IP=$(curl http://checkip.amazonaws.com)  # optional. must resolve to the IP you are requesting from

NODE_CLI="/usr/local/bin/cardano-cli"
NODE_LOG_DIR="${NODE_HOME}/logs"
GENESIS_JSON="${NODE_HOME}/config/${NODE_NETWORK}-shelley-genesis.json"
NETWORKID=$(jq -r .networkId $GENESIS_JSON)
NODE_VALENCY=1   # optional for multi-IP hostnames
NWMAGIC=$(jq -r .networkMagic < $GENESIS_JSON)
[[ "${NETWORKID}" = "Mainnet" ]] && HASH_IDENTIFIER="--mainnet" || HASH_IDENTIFIER="--testnet-magic ${NWMAGIC}"
[[ "${NWMAGIC}" = "764824073" ]] && NETWORK_IDENTIFIER="--mainnet" || NETWORK_IDENTIFIER="--testnet-magic ${NWMAGIC}"
 
export CARDANO_NODE_SOCKET_PATH="${NODE_HOME}/sockets/node.socket"
NODE_BLOCK=$($NODE_CLI query tip ${NETWORK_IDENTIFIER} | jq -r .block )
 
# Note:
# if you run your node in IPv4/IPv6 dual stack network configuration and want announced the
# IPv4 address only please add the -4 parameter to the curl command below  (curl -4 -s ...)
if [ "${NODE_EXTERNAL_IP}" != "CHANGE ME" ]; then
  T_HOSTNAME="&hostname=${NODE_EXTERNAL_IP}"
else
  T_HOSTNAME=''
fi

if [ ! -d ${NODE_LOG_DIR} ]; then
  mkdir -p ${NODE_LOG_DIR};
fi

if [ -n "$NODE_BLOCK" ]
then
  curl -s "https://api.clio.one/htopology/v1/?port=${NODE_PORT}&blockNo=${NODE_BLOCK}&valency=${NODE_VALENCY}&magic=${NWMAGIC}${T_HOSTNAME}" 
  #| tee -a $NODE_LOG_DIR/topologyUpdater_lastresult.json
else
  echo "WARNING Can't obtain block number from node. Can't push. Cardano already starting?"
fi
