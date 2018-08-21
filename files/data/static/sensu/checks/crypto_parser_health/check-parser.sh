#!/bin/bash

if [ -z $1 ]; then
  echo "CRIT: improper arguments passed"
  exit 2
fi

URL=$1

OUT=`curl $URL 2>/dev/null`
RC=$?
if [ "$RC" -ne "0" ]; then
  echo "CRIT: URL is not reachable"
  exit 2
fi

echo $OUT | jq '.data|ascii_downcase == "ok"' | grep -q "true"
RC=$?

if [ "$RC" -ne "0" ]; then
  echo "CRIT: parser does not respond"
  exit 2
else
  echo "OK: Parser is working"
  exit 0
fi
