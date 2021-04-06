
#!/bin/bash
if [ -n "$NODE_CORE" ]
then
    BLOCKPRODUCING_IP=$(echo $NODE_CORE|awk -F':' '{print $1}')
    BLOCKPRODUCING_PORT=$(echo $NODE_CORE|awk -F':' '{print $2}')
    curl -s -o /home/cardano/cnode/config/mainnet-topology.json "https://api.clio.one/htopology/v1/fetch/?max=20&customPeers=${BLOCKPRODUCING_IP}:${BLOCKPRODUCING_PORT}:1|relays-new.cardano-mainnet.iohk.io:3001:2"
else
    curl -s -o /home/cardano/cnode/config/mainnet-topology.json "https://api.clio.one/htopology/v1/fetch/?max=20&customPeers=relays-new.cardano-mainnet.iohk.io:3001:2"
fi
