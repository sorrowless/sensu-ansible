#!/bin/bash

INSTALLED_OUT=`curl -X POST --header "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":67}' localhost:9656 2>/dev/null`
RC=$?

if [[ $RC -ne 0 ]]; then
  echo "CRITICAL: Call to running Geth instanse returned ${RC} as exit code."
  exit 2
fi

INSTALLED_VERSION=`echo ${INSTALLED_OUT} | jq '.result' | perl -pe 's|"Geth\/v(.*?)-[\w/.-]+"$|\1|'`

# Cache update only if it is older then a 12 hours
last_update=$(stat -c %Y /var/cache/apt/pkgcache.bin)
now=$(date +%s)
if [ $((now - last_update)) -gt 43200 ]; then
  apt-get update 2>/dev/null
fi

APT_INFO=`apt-cache policy geth`
RC=$?

if [[ $RC -ne 0 ]]; then
  echo "CRITICAL: apt-cache policy returned ${RC}"
  exit 2
fi

APT_INSTALLED=`echo ${APT_INFO} | perl -ne 'print $1 if m|\s+Installed:\s([\d.]+)\+.*|'`
APT_CANDIDATE=`echo ${APT_INFO} | perl -ne 'print $1 if m|\s+Candidate:\s([\d.]+)\+.*|'`

WARNING=0
INSTALLED_MSG=""
if [[ $APT_INSTALLED != $INSTALLED_VERSION ]]; then
  INSTALLED_MSG="Running version is ${INSTALLED_VERSION} but APT says that installed is ${APT_INSTALLED} - looks that current version was installed not from repositories. Latest available in Ubuntu repositories version is ${APT_CANDIDATE}."
  WARNING=1
fi

CANDIDATE_MSG=""
if [[ $APT_CANDIDATE != $INSTALLED_VERSION ]] && [[ $WARNING -eq 0 ]]; then
  CANDIDATE_MSG="Running version of geth is ${INSTALLED_VERSION} but latest available version in repos is ${APT_CANDIDATE}."
  WARNING=1
fi

if [[ $WARNING -eq 0 ]]; then
  echo "OK: Installed version is ${INSTALLED_VERSION}, APT latest version is ${APT_CANDIDATE}, current version installed from APT"
  exit 0
else
  echo "WARNING: ${INSTALLED_MSG} ${CANDIDATE_MSG}"
  exit 1
fi
