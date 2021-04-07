
#!/bin/bash
if [ -n "$1" ]
then
    $NODE_CUSTOM_PEERS_P=$(echo "$1"|sed -e 's/,/\|/g')
    curl -s -o /home/cardano/cnode/config/mainnet-topology.json "https://api.clio.one/htopology/v1/fetch/?max=20&customPeers=${NODE_CUSTOM_PEERS_P}"
else
    curl -s -o /home/cardano/cnode/config/mainnet-topology.json "https://api.clio.one/htopology/v1/fetch/?max=20&customPeers=relays-new.cardano-mainnet.iohk.io:3001:2"
fi
