#!/bin/bash
# create tunnel ssh keys

KEY="tun.key"
ssh-keygen -t "ecdsa" -b 521 -P "" -f "$KEY"
