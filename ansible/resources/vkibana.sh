#!/bin/bash
# vagrant tpot kibana ssh port forward

ssh -p64295 -L 8080:localhost:64296 vagrant@localhost -N
