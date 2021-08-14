#!/usr/bin/env bash

rm -rf contracts/flat
ROOT=contracts/

POSDAO=posdao/
POSDAO_FULLPATH="$ROOT""$POSDAO"

POSDAO_UPGRADEABILITY="$POSDAO"upgradeability/
POSDAO_UPGRADEABILITY_FULLPATH="$ROOT""$POSDAO_UPGRADEABILITY"

DAO=dao/
DAO_FULLPATH="$ROOT""$DAO"

FLAT=contracts/flat/

FULLPATH="$(cd "$(dirname "$1")" || exit; pwd -P)/$(basename "$1")"

iterate_sources() {
    for FILE in "$FULLPATH""$1"*.sol; do
        [ -f "$FILE" ] || break
        echo "$FILE"
        ./node_modules/.bin/poa-solidity-flattener "$FILE" "$2"
    done
}

mkdir -p "$FLAT""$POSDAO";

iterate_sources "$POSDAO_FULLPATH" "$FLAT""$POSDAO"

mkdir -p "$FLAT""$POSDAO_UPGRADEABILITY";

iterate_sources "$POSDAO_UPGRADEABILITY_FULLPATH" "$FLAT""$POSDAO_UPGRADEABILITY"

mkdir -p "$FLAT""$DAO";

iterate_sources "$DAO_FULLPATH" "$FLAT""$DAO"

