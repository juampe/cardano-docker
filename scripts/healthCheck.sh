#!/bin/bash

#If not true all is ok, no health
if [ "$NODE_HEALTH" != "true" ]
then
    exit 0
fi

#If exist this file all is ok, no health
if [ -e "$NODE_HOME/DISABLE_HEALTH"  ]
then
    exit 0
fi

if [ -n "$NODE_HEALTH_TIMEOUT" ]
then
    TIMEOUT=$NODE_HEALTH_TIMEOUT
else
    TIMEOUT=$1
fi

if [ -z "$TIMEOUT" ]
then
    TIMEOUT=120
fi

export CARDANO_NODE_SOCKET_PATH="$NODE_HOME/sockets/node.socket"
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
