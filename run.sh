#!/bin/bash

NETWORK=$1
TYPE=$2

function run_sparta() {
case "$TYPE" in
"rpc")
  echo "==> Running a node for SPARTA configured with exposed RPC"
  echo "==> Checking docker instalation..."
  bash scripts/docker.sh &> /dev/null

;;
"validator")
  echo "==> Running a node for SPARTA configured with validator configuration"

;;
"node")
  echo "==> Running a simple node for SPARTA"

;;
"explorer")
  echo "==> Running a node for SPARTA with and blockscout instance"

;;
*)
    echo "Unknown configuration type for SPARTA please specify a node setup: rpc, explorer, validator, node"
    ;;
esac
}

function run_athene() {
case "$TYPE" in
"rpc")
  echo "==> Running a node for ATHENE configured with exposed RPC"

;;
"validator")
  echo "==> Running a node for ATHENE configured with VALIDATOR configuration"

;;
"node")
  echo "==> Running a simple node for ATHENE"

;;
"explorer")
  echo "==> Running a node for ATHENE with and BLOCKSCOUT instance"

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
"athene")
      run_athene
;;
*)
    echo "Unknown network, please specify sparta (for testnet) athene (for mainnet)"
    exit
    ;;
esac
}

run