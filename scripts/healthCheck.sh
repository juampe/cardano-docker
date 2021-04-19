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

#first check io wait
IOWAIT=$(vmstat 10 2|tail -1|awk '{print $16}')
if [ "$IOWAIT" -gt "90" ]
then
    TIMERANGE=$((($TIMEOUT*3)-15))
    #seem iowait is high, go to see if in TIMERANGE time range is high too
    IOWAIT=$(vmstat $TIMERANGE 2|tail -1|awk '{print $16}')
    if [ "$IOWAIT" -gt "95" ]
    then
        exit 1
    fi
fi

#second check cardano tip
export CARDANO_NODE_SOCKET_PATH="$NODE_HOME/sockets/node.socket"
if [ -S "$CARDANO_NODE_SOCKET_PATH" ]
then
    #started and respond to query
    timeout $TIMEOUT /usr/local/bin/cardano-cli query tip --${NODE_NETWORK} > /dev/null 2>&1
    ERROR=$?
    exit $ERROR
else
    #There aren't socket, not started yet
    exit 0
fi
