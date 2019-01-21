#!/bin/bash

PORT="${1:-9656}"
OUT=`geth attach http://localhost:$PORT --exec "eth.blockNumber" 2>&1`
RC=$?

if [[ $RC -eq 0 ]]; then
  echo "OK: Returned block number is ${OUT}"
  exit 0
else
  echo "Critical: geth command returns: ${OUT}"
  exit 2
fi
