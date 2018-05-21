#!/bin/bash

PORT="${1:-9656}"
OUT=`geth attach http://localhost:${PORT} --exec "eth.pendingTransactions.length" 2>&1`
RC=$?

if [[ $RC -eq 0 ]]; then
  if [[ $OUT -lt 10 ]]; then
    echo "OK: Geth eth.pendingTransactions.length is ${OUT}"
    exit 0
  else
    echo "Critical: geth command returns: $OUT"
    exit 2
  fi    
else
  echo "Critical: geth command returns: $OUT"
  exit 2
fi
