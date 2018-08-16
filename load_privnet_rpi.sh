#!/bin/bash
# create geth.ipc
./log_nodeInfo.sh
networkId=4828
port=30303
rpcport=8545

# before starting DDASH, need to start geth daemon

# mine if the machine architecture is not arm (raspberry pi)
arch="$(dpkg --print-architecture)"
echo $arch
if [[ "$arch" == 'armhf' ]]; then
	echo "exit" | geth --verbosity 2 --datadir=$PWD/simbel/data_privnet --networkid "$networkId" --port "$port" --rpc --rpcport "$rpcport" console

	tmux new-session -d -s geth "geth --verbosity 3 --datadir=$PWD/simbel/data_privnet --networkid $networkId --port $port  --rpcapi=\"db,eth,net,personal,web3\" --rpc --rpcport $rpcport console"
else
	echo "exit" | geth --verbosity 2 --datadir=$PWD/simbel/data_privnet --networkid "$networkId" --port "$port" --rpc --rpcport "$rpcport" console

	tmux new-session -d -s geth "geth --verbosity 3 --datadir=$PWD/simbel/data_privnet --networkid $networkId --port $port  --rpcapi=\"db,eth,net,personal,web3\" --rpc --rpcport $rpcport --mine --minerthreads=1 console"
fi

#tmux new-session -d -s ipfs 'ipfs daemon'
sleep 5

