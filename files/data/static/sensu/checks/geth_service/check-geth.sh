#!/bin/bash

PORT="${1:-9656}"
OUT=`geth attach http://localhost:$PORT --exec "eth.syncing" 2>&1`
IS_FALSE=`echo $OUT | grep -q "false"`
RC=$?

if [[ $RC -eq 0 ]]; then
  echo "OK: Geth eth.syncing is false"
  exit 0
else
  echo "Critical: geth command returns: $OUT"
  exit 2
fi
