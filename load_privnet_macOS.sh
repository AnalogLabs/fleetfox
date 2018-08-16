#!/bin/bash
# create geth.ipc
./log_nodeInfo.sh
networkId=4828
port=30303
rpcport=8545

echo "exit" | ./geth_macOS --verbosity 2 --datadir=$PWD/simbel/data_privnet --networkid "$networkId" --port "$port" --rpc --rpcport "$rpcport" console

./geth_macOS --verbosity 3 --datadir=$PWD/simbel/data_privnet --networkid $networkId --port $port  --rpcapi=\"db,eth,net,personal,web3\" --rpc --rpcport $rpcport console

sleep 5

