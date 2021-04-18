#!/bin/bash
CARDANO_NODE_SOCKET_PATH="$NODE_HOME/sockets/node.socket"
TIMEOUT=$1
if [ -S "$CARDANO_NODE_SOCKET_PATH" ]
then
    #started and respond to query
    timeout $TIMEOUT /usr/local/bin/cardano-cli query tip --$NODE_NETWORK > /dev/null 2>&1
    exit $?
else
    #not started yet
    exit 0
fi
