#!/bin/bash
# create geth.ipc
#./log_nodeInfo.sh
#echo "exit" | geth --verbosity 2 --datadir=$PWD/simbel/data console

# before starting DDASH, need to start IPFS and geth daemons
    #tmux new-session -d -s geth "geth --verbosity 2 --datadir=$PWD/simbel/data --networkid 4828 --port 30303 --rpcapi=\"db,eth,net,personal,web3\" --rpc --rpcport 8545 console"

tmux new-session -d -s geth "./geth_macOS --verbosity 3 --syncmode light console"

#tmux new-session -d -s ipfs 'ipfs daemon'
sleep 5

#python3 $PWD/simbel/main.py


