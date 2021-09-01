#!/bin/bash

SPARTA_EXPLORER="https://sparta-explorer.polis.tech/"
OLYMPUS_EXPLORER="https://explorer.polis.tech/"

FETCH_LAST_BLOCK_ENDPOINT="api/?module=block&action=eth_block_number"
BLOCK_DATA_ENDPOINT="graphiql"

function fetch_block_data() {
  url="$1""$BLOCK_DATA_ENDPOINT"
  BLOCK_NUMBER="$2"
  curl -H 'Content-Type: application/json' -X POST -d '{ "query": "query { block(number: '"$BLOCK_NUMBER"') { hash, totalDifficulty }}" }' "$url" > block_info.txt
  BLOCK_HASH=$(sed -E 's/.*"hash":"?([^,"]*)"?.*/\1/' block_info.txt)
  BLOCK_TOTAL_DIFFICULTY=$(sed -E 's/.*"totalDifficulty":"?([^,"]*)"?.*/\1/' block_info.txt)
  rm -rf block_info.txt
}

function fetch_last_block() {
  url="$1""$FETCH_LAST_BLOCK_ENDPOINT"
  curl "$url" -H "Accept: application/json" > block_data.txt
  BLOCK_NUMBER=$(($(sed -E 's/.*"result":"?([^,"]*)"?.*/\1/' block_data.txt)))
  rm -rf block_data.txt
  fetch_block_data "$1" "$BLOCK_NUMBER"
}

function update_sparta() {
  sed -i 's/\"PivotNumber\":.*/\"PivotNumber\": '"$BLOCK_NUMBER"',/g' "./specs/configs/sparta.cfg"
  sed -i 's/\"PivotHash\":.*/\"PivotHash\": "'"$BLOCK_HASH"'",/g' "./specs/configs/sparta.cfg"
  sed -i 's/\"PivotTotalDifficulty\":.*/\"PivotTotalDifficulty\": "'"$BLOCK_TOTAL_DIFFICULTY"'",/g' "./specs/configs/sparta.cfg"

  sed -i 's/\"PivotNumber\":.*/\"PivotNumber\": '"$BLOCK_NUMBER"',/g' "./specs/configs/sparta_validator.cfg"
  sed -i 's/\"PivotHash\":.*/\"PivotHash\": "'"$BLOCK_HASH"'",/g' "./specs/configs/sparta_validator.cfg"
  sed -i 's/\"PivotTotalDifficulty\":.*/\"PivotTotalDifficulty\": "'"$BLOCK_TOTAL_DIFFICULTY"'",/g' "./specs/configs/sparta_validator.cfg"
}

function update_olympus() {
  sed -i 's/\"PivotNumber\":.*/\"PivotNumber\": '"$BLOCK_NUMBER"',/g' "./specs/configs/olympus.cfg"
  sed -i 's/\"PivotHash\":.*/\"PivotHash\": "'"$BLOCK_HASH"'",/g' "./specs/configs/olympus.cfg"
  sed -i 's/\"PivotTotalDifficulty\":.*/\"PivotTotalDifficulty\": "'"$BLOCK_TOTAL_DIFFICULTY"'",/g' "./specs/configs/olympus.cfg"

  sed -i 's/\"PivotNumber\":.*/\"PivotNumber\": '"$BLOCK_NUMBER"',/g' "./specs/configs/olympus_validator.cfg"
  sed -i 's/\"PivotHash\":.*/\"PivotHash\": "'"$BLOCK_HASH"'",/g' "./specs/configs/olympus_validator.cfg"
  sed -i 's/\"PivotTotalDifficulty\":.*/\"PivotTotalDifficulty\": "'"$BLOCK_TOTAL_DIFFICULTY"'",/g' "./specs/configs/olympus_validator.cfg"
}

function fetch_sparta() {
  fetch_last_block "$SPARTA_EXPLORER"
  update_sparta
}

function fetch_olympus() {
  fetch_last_block "$OLYMPUS_EXPLORER"
  update_olympus
}


run() {
case "$1" in
"sparta")
  fetch_sparta
;;
"olympus")
  fetch_olympus
;;
*)
echo "Please specify a network (sparta or olympus)"
;;
esac
}

run "$1"
