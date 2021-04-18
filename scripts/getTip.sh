#!/bin/bash
CARDANO_NODE_SOCKET_PATH="$NODE_HOME/sockets/node.socket" /usr/local/bin/cardano-cli query tip --$NODE_CONFIG
