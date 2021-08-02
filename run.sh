#!/bin/bash

NETWORK=$1
TYPE=$2
ACCOUNT=$3

function run_sparta_simple() {
    echo "==> Starting Polis node on SPARTA network"
  	docker run -d \
		-e NETHERMIND_CONFIG=sparta \
		-v /root/polis-chains/configs/sparta/static-nodes.json:/nethermind/Data/static-nodes.json \
 		-v /root/nethermind_db/:/nethermind/nethermind_db/ \
 		-v /root/logs/:/nethermind/logs/ \
 		-e NETHERMIND_MININGCONFIG_MINGASPRICE="1000000000" \
 		ghcr.io/polischain/polis-chains:main
}

function run_sparta_rpc() {
  echo "==> Starting Polis node on SPARTA network and JSON RPC exposed"
  docker run -d \
		-e NETHERMIND_CONFIG=sparta \
		-e NETHERMIND_INITCONFIG_WEBSOCKETSENABLED=true \
		-e NETHERMIND_JSONRPCCONFIG_WEBSOCKETSPORT=8546 \
		-e NETHERMIND_JSONRPCCONFIG_ENABLEDMODULES=eth,subscribe,trace,txpool,web3,proof,net,parity,health \
		-e NETHERMIND_JSONRPCCONFIG_ENABLED=true \
		-e NETHERMIND_JSONRPCCONFIG_HOST=127.0.0.1 \
		-p 8545:8545 \
		-p 8546:8546 \
		-v /root/polis-chains/configs/sparta/static-nodes.json:/nethermind/Data/static-nodes.json \
 		-v /root/nethermind_db/:/nethermind/nethermind_db/ \
 		-v /root/logs/:/nethermind/logs/ \
 		ghcr.io/polischain/polis-chains:main
}

function run_sparta_validator() {
  echo "==> Starting Polis node on SPARTA network and enabled for mining"
	docker run -d \
		-p 30303:30303 \
		-e NETHERMIND_CONFIG=sparta \
		-e NETHERMIND_INITCONFIG_ISMINING="true" \
		-e NETHERMIND_MININGCONFIG_ENABLED="true" \
		-e NETHERMIND_MININGCONFIG_MINGASPRICE="1000000000" \
		-e NETHERMIND_MININGCONFIG_TARGETBLOCKGASLIMIT="20000000" \
		-e NETHERMIND_KEYSTORECONFIG_BLOCKAUTHORACCOUNT="$ACCOUNT" \
		-e NETHERMIND_KEYSTORECONFIG_UNLOCKACCOUNTS="$ACCOUNT" \
		-e NETHERMIND_KEYSTORECONFIG_PASSWORDFILES=/nethermind/passwords/node.pwd \
		-v /root/polis-chains/configs/sparta/static-nodes.json:/nethermind/Data/static-nodes.json \
		-v /root/passwords/:/nethermind/passwords/ \
 		-v /root/nethermind_db/:/nethermind/nethermind_db/ \
 		-v /root/keystore/:/nethermind/keystore \
 		-v /root/logs/:/nethermind/logs/ \
 		ghcr.io/polischain/polis-chains:main
}

function run_sparta() {
case "$TYPE" in
"rpc")
  echo "==> Running a node for SPARTA configured with exposed RPC"
  echo "==> Checking docker installation..."
  bash scripts/docker.sh &> /dev/null
  run_sparta_rpc
;;
"validator")
  echo "==> Running a node for SPARTA configured with validator configuration"
  echo "==> Checking docker installation..."
  bash scripts/docker.sh &> /dev/null
  if [ "$ACCOUNT" == "" ]
    then
      echo "Please specify the account used to mine as the third argument (./run.sh sparta validator 0x123...123"
    else
      run_sparta_validator
  fi
;;
"node")
  echo "==> Running a simple node for SPARTA"
  echo "==> Checking docker installation..."
  bash scripts/docker.sh &> /dev/null
  run_sparta_simple
;;
"explorer")
  echo "==> Running a node for SPARTA with and blockscout instance"
  echo "==> Checking docker installation..."
  bash scripts/docker.sh &> /dev/null
  echo "==> Checking rust installation..."
  bash scripts/rust.sh &> /dev/null

;;
*)
    echo "Unknown configuration type for SPARTA please specify a node setup: rpc, explorer, validator, node"
    ;;
esac
}

function run() {
  echo "==> Running a node for $NETWORK configured for  $TYPE"
case "$NETWORK" in
"sparta")
      run_sparta
;;
*)
    echo "Unknown network, please specify sparta (for testnet)"
    exit
    ;;
esac
}

run