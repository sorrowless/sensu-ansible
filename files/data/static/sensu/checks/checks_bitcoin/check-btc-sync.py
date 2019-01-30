#!/usr/bin/python3

import requests
import sys

usage = """
Usage:
    check-bitcoin-sync.py <blockchainApiUrl> <localBtcUrl> [blocksCountAlert]

where:
    blockchainApiUrl is an URL to blockchain.info
    localBtcUrl is an URL to local bitcoind instance like
                     http://localhost:18332
    blocksCountAlert is a difference of blocks to alert about. Optional,
                     default value is 10
"""

if len(sys.argv) < 3:
    print(usage)
    sys.exit(2)

# Getting local block number
local_btc_url = sys.argv[2]
payload = '{"jsonrpc":"1.0","id":"curltext","method":"getblockcount","params":[]}'  # noqa
headers = {'Content-Type': 'text/plain'}
r = requests.post(local_btc_url, data=payload, headers=headers)
local_bnum = int(r.json()['result'])

# Getting remote block number
remote_btc_url = sys.argv[1]

r = requests.get(remote_btc_url)
remote_bnum = int(r.json()['height'])

# Calc and alert if unsync is too big
message = "remote block number is {}, local is {}".format(
        remote_bnum, local_bnum)
blocks_diff = int(sys.argv[3]) if len(sys.argv) == 4 else 10
if remote_bnum - local_bnum > blocks_diff:
    print("CRITICAL: %s, that's a problem" % message)
    sys.exit(2)

print("OK: %s" % message)
