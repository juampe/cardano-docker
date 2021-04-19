#!/bin/bash
#set -xv

#If not true all is ok
if [ "$NODE_HEALTH" != "true" ]
then
    exit 0
fi

export CARDANO_NODE_SOCKET_PATH="$NODE_HOME/sockets/node.socket"

TIMEOUT=$1

if [ -z "$TIMEOUT" ]
then
    TIMEOUT=120
fi

if [ -S "$CARDANO_NODE_SOCKET_PATH" ]
then
    #started and respond to query
    timeout $TIMEOUT /usr/local/bin/cardano-cli query tip --${NODE_NETWORK} > /dev/null 2>&1
    ERROR=$?
    # echo "TIMEOUT $TIMEOUT CODE $ERROR"
    # if [ "$ERROR" -eq "1"  ]
    # then
    #     #socket not ready
    #     echo "EXIT 0"
    #     exit 0
    # fi
    exit $ERROR
else
    #There aren't socket, not started yet
    exit 0
fi
