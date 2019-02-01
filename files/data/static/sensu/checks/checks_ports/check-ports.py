#!/usr/bin/python3

import argparse
import socket
import sys


parser = argparse.ArgumentParser(
        description='Check host for opened/closed ports')
parser.add_argument(
        '--host',
        help='Host to check ports against',
        default='127.0.0.1',
        type=str)
parser.add_argument(
        '-p', '--ports',
        help='Ports to check divided by space',
        default=[80],
        metavar='port',
        nargs='+'
        )
parser.add_argument(
        '-r', '--reverse',
        help='If specified, return OK for CLOSED port instead of opened one',
        action='store_true')
parser.add_argument(
        '-t', '--timeout',
        help='Time to wait for host answered to connection',
        default=5,
        type=int)
args = parser.parse_args()

status_ok = 'OK'
status_critical = 'CRITICAL'
problems_found = False
messages = list()
for port in args.ports:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.settimeout(args.timeout)
        try:
            current_status = status_ok
            add = ""
            sock.connect((args.host, int(port)))
            if args.reverse:
                problems_found = True
                current_status = status_critical
                add = " but that's not ok as we check for closed ports"
            message = "  {status}: {host}:{port} is available{add}".format(
                    status=current_status,
                    host=args.host,
                    port=port,
                    add=add)
        except socket.error as e:
            current_status = status_ok
            add = ""
            if not args.reverse:
                problems_found = True
                current_status = status_critical
            else:
                add = " but that's ok as we check for closed ports"
            message = "  {status}: We got an '{err}' for {host}:{port}{add}".format(  # noqa
                    status=current_status,
                    err=e,
                    host=args.host,
                    port=port,
                    add=add)
        finally:
            messages.append(message)

message = ',\n'.join(messages)
if problems_found:
    print('CRITICAL: Results per port: \n\n{msg}'.format(msg=message))
    sys.exit(2)
else:
    print('OK: Results per port: \n\n{msg}'.format(msg=message))
