#!/bin/bash

NETWORK=$1
TYPE=$2
ACCOUNT=$3

function run_sparta_simple_archived() {
  echo "==> Starting Polis node on SPARTA network"
  docker run -d --restart=always \
    -p 30303:30303 \
    -p 30303:30303/udp \
    -e NETHERMIND_CONFIG=sparta_archive \
    -e NETHERMIND_ETHSTATSCONFIG_ENABLED="true" \
    -e NETHERMIND_ETHSTATSCONFIG_SECRET="PhD8zsx69jhpqv7PUhzz2mExj66hT8tRknP7Rw7sCC5y79SAgQuZLW6cXUuqjRnv" \
    -e NETHERMIND_ETHSTATSCONFIG_SERVER="wss://sparta-stats.polis.tech/api" \
    -e NETHERMIND_ETHSTATSCONFIG_NAME="$NAME" \
    -e NETHERMIND_MININGCONFIG_MINGASPRICE="1000000000" \
    -v "$(pwd)"/db/:/nethermind/nethermind_db/ \
    -v "$(pwd)"/keystore/:/nethermind/keystore/ \
    -v "$(pwd)"/logs/:/nethermind/logs/ \
    ghcr.io/polischain/polis-chains:main
}

function run_sparta_simple() {
  echo "==> Starting Polis node on SPARTA network"
  docker run -d --restart=always \
    -p 30303:30303 \
    -p 30303:30303/udp \
    -e NETHERMIND_CONFIG=sparta \
    -e NETHERMIND_ETHSTATSCONFIG_ENABLED="true" \
    -e NETHERMIND_ETHSTATSCONFIG_SECRET="PhD8zsx69jhpqv7PUhzz2mExj66hT8tRknP7Rw7sCC5y79SAgQuZLW6cXUuqjRnv" \
    -e NETHERMIND_ETHSTATSCONFIG_SERVER="wss://sparta-stats.polis.tech/api" \
    -e NETHERMIND_ETHSTATSCONFIG_NAME="$NAME" \
    -e NETHERMIND_MININGCONFIG_MINGASPRICE="1000000000" \
    -v "$(pwd)"/db/:/nethermind/nethermind_db/ \
    -v "$(pwd)"/keystore/:/nethermind/keystore/ \
    -v "$(pwd)"/logs/:/nethermind/logs/ \
    ghcr.io/polischain/polis-chains:main
}

function run_sparta_rpc() {
  echo "==> Starting Polis node on SPARTA network and JSON RPC exposed"
  docker run -d --restart=always \
    -p 30303:30303 \
    -p 30303:30303/udp \
    -e NETHERMIND_CONFIG=sparta \
    -e NETHERMIND_ETHSTATSCONFIG_ENABLED="true" \
    -e NETHERMIND_ETHSTATSCONFIG_SECRET="PhD8zsx69jhpqv7PUhzz2mExj66hT8tRknP7Rw7sCC5y79SAgQuZLW6cXUuqjRnv" \
    -e NETHERMIND_ETHSTATSCONFIG_SERVER="wss://sparta-stats.polis.tech/api" \
    -e NETHERMIND_ETHSTATSCONFIG_NAME="$NAME" \
    -e NETHERMIND_INITCONFIG_WEBSOCKETSENABLED=true \
    -e NETHERMIND_JSONRPCCONFIG_WEBSOCKETSPORT=8546 \
    -e NETHERMIND_JSONRPCCONFIG_ENABLEDMODULES=eth,subscribe,trace,txpool,web3,proof,net,parity,health \
    -e NETHERMIND_JSONRPCCONFIG_ENABLED=true \
    -e NETHERMIND_JSONRPCCONFIG_HOST=0.0.0.0 \
    -p 8545:8545 \
    -p 8546:8546 \
    -v "$(pwd)"/db/:/nethermind/nethermind_db/ \
    -v "$(pwd)"/keystore/:/nethermind/keystore/ \
    -v "$(pwd)"/logs/:/nethermind/logs/ \
    ghcr.io/polischain/polis-chains:main
}

function run_sparta_validator() {
  echo "==> Starting Polis node on SPARTA network and enabled for mining"
	docker run -d --restart=always \
    -p 30303:30303 \
    -p 30303:30303/udp \
    -e NETHERMIND_CONFIG=sparta_validator \
    -e NETHERMIND_ETHSTATSCONFIG_ENABLED="true" \
    -e NETHERMIND_ETHSTATSCONFIG_SECRET="PhD8zsx69jhpqv7PUhzz2mExj66hT8tRknP7Rw7sCC5y79SAgQuZLW6cXUuqjRnv" \
    -e NETHERMIND_ETHSTATSCONFIG_SERVER="wss://sparta-stats.polis.tech/api" \
    -e NETHERMIND_ETHSTATSCONFIG_NAME="$NAME" \
    -e NETHERMIND_INITCONFIG_ISMINING="true" \
    -e NETHERMIND_MININGCONFIG_ENABLED="true" \
    -e NETHERMIND_MININGCONFIG_MINGASPRICE="1000000000" \
    -e NETHERMIND_MININGCONFIG_TARGETBLOCKGASLIMIT="20000000" \
    -e NETHERMIND_KEYSTORECONFIG_BLOCKAUTHORACCOUNT="$ACCOUNT" \
    -e NETHERMIND_KEYSTORECONFIG_UNLOCKACCOUNTS="$ACCOUNT" \
    -e NETHERMIND_KEYSTORECONFIG_PASSWORDFILES=/nethermind/passwords/"$ACCOUNT" \
    -v "$(pwd)"/passwords/:/nethermind/passwords/ \
    -v "$(pwd)"/db/:/nethermind/nethermind_db/ \
    -v "$(pwd)"/keystore/:/nethermind/keystore \
    -v "$(pwd)"/logs/:/nethermind/logs/ \
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
"node_archived")
  echo "==> Running a simple node for SPARTA"
  echo "==> Checking docker installation..."
  bash scripts/docker.sh &> /dev/null
  run_sparta_simple_archived
;;
*)
echo "Unknown configuration type for SPARTA please specify a node setup: rpc, explorer, validator, node"
    ;;
esac
}

function run_gen() {
      echo "==> This function will create a new key with a random password"
      echo "==> Your keys are stored at $(pwd)/keystore and your passwords in $(pwd)/passwords"
      echo "==> Make sure you backup those folders to prevent missing keys"
      mkdir -p keystore
      mkdir -p passwords
      password=$(openssl rand -hex 32)
      cd keygen && npm i; cd - || exit
      node keygen/index.js "$password"
}

function run() {
  echo "==> Running a node for $NETWORK configured for  $TYPE"
case "$NETWORK" in
"sparta")
      run_sparta
      screen -dm watch -n 30 ./scripts/fixtime.sh
;;
"generate")
      run_gen
;;
*)
    echo "Unknown network, please specify sparta (for testnet)"
    exit
    ;;
esac
}

run