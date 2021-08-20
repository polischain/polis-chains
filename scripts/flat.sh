#!/usr/bin/env bash

rm -rf flat
ROOT=contracts/

POSDAO=posdao/
POSDAO_FULLPATH="$ROOT""$POSDAO"

POSDAO_UPGRADEABILITY="$POSDAO"upgradeability/
POSDAO_UPGRADEABILITY_FULLPATH="$ROOT""$POSDAO_UPGRADEABILITY"

DAO=dao/
DAO_FULLPATH="$ROOT""$DAO"

FLAT=flat/

iterate_sources() {
  files=$(ls "$1"*.sol)
  for file in $files; do
    file_name=$(basename "$file")
    hardhat flatten "$file" > "$2""$file_name"
  done
}

mkdir -p "$FLAT""$POSDAO";

iterate_sources "$POSDAO_FULLPATH" "$FLAT""$POSDAO"

mkdir -p "$FLAT""$POSDAO_UPGRADEABILITY";

iterate_sources "$POSDAO_UPGRADEABILITY_FULLPATH" "$FLAT""$POSDAO_UPGRADEABILITY"

mkdir -p "$FLAT""$DAO";

iterate_sources "$DAO_FULLPATH" "$FLAT""$DAO"

