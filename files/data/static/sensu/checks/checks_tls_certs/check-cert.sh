#!/bin/bash

CERT=${1:-nothing}
EXPWARN=${2:-604800}  # One week by default
EXPCRIT=${3:-172800}  # Two days by default

openssl x509 -in ${CERT} -checkend 0 | grep 'not expire' -q
RC=$?

if [ "$RC" -ne "0" ]; then
  echo "CRIT: ${CERT} is expired"
  exit 2
fi

openssl x509 -in ${CERT} -checkend ${EXPCRIT} | grep 'not expire' -q
RC=$?

if [ "$RC" -ne "0" ]; then
  echo "CRIT: ${CERT} will be expired soon"
  exit 1
fi

openssl x509 -in ${CERT} -checkend ${EXPWARN} | grep 'not expire' -q
RC=$?

if [ "$RC" -ne "0" ]; then
  echo "WARN: ${CERT} needs to be rotated"
  exit 0
else
  RES=$(awk "BEGIN{print ${EXPWARN}/86400}")
  echo "OK: ${CERT} won't expire in ${RES} days"
  exit 0
fi
