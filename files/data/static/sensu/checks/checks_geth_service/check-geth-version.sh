#!/bin/bash

OUT=`geth version | egrep '^(Version|Git Commit)' 2>&1`
RC=$?

if [[ $RC -eq 0 ]]; then
  echo "OK: Returned info is ${OUT}"
  exit 0
else
  echo "Critical: geth command returns: ${OUT}"
  exit 2
fi
