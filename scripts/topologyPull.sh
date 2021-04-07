
#!/bin/bash
if [ -n "$1" ]
then
    MAX=$2
    NODE_CUSTOM_PEERS_P=$(echo "$1"|sed -e 's/,/\|/g')
    curl -s -o /home/cardano/cnode/config/mainnet-topology.json "https://api.clio.one/htopology/v1/fetch/?max=${MAX}&customPeers=${NODE_CUSTOM_PEERS_P}"
else
    MAX=$2
    curl -s -o /home/cardano/cnode/config/mainnet-topology.json "https://api.clio.one/htopology/v1/fetch/?max=${MAX}&customPeers=relays-new.cardano-mainnet.iohk.io:3001:2"
fi
