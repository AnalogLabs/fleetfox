# Fleet Fox 
## Blockchain Messaging Service
![Fleet Fox Logo](https://fleetfox.nyc3.digitaloceanspaces.com/diy_instructions/fox.png)

## What is Fleet Fox?
Fleet Fox is a system that lets users pin messages and value to any 3-dimensional coordinate on Earth.

A "Checkpoint" corresponds to a physical location in the form of "longitude,latitude,altitude".

Checkpoints can be initialized to contain an associated message, token, and/or Ether bounty awarded to whomever pings the smart contract from a specific GPS location.

The Fleet Fox application runs on the Ethereum blockchain, and the hardware is based on a GPS module interfacing with an ultra low-energy display.

## Why Fleet Fox?
Fleet Fox allows users to design geolocation-based incentive programs and securely send and receive information and value.

The Ethereum blockchain backend also lends Fleet Fox these built-in features:

* Secure Blockchain Messaging Service

* Geolocation-based payment system

* Funding model for Emergency Medical Services, especially in under-served geographic areas

* P2P blockchain backend for business-to-consumer fleet sharing services (vehicles, bicycles, electric scooters)

* Organizational logic for peer-to-peer vehicle sharing services

* Collaborative map-making and location sharing


## Fleet Fox Receiver
The Fleet Fox receiver can be assembled with open-source hardware.

Components:

* Raspberry Pi or similar Linux-based microcontroller
* Battery pack
* Display 
* GPS module

The receiver prototype is also available ready to use out-of-the-box as a [kit available for purchase through Analog Labs](https://fleetfox.nyc3.digitaloceanspaces.com/diy_instructions/fox.png). Each kit includes an illustrated instruction manual on how to assemble a Fleet Fox receiver and use it to pin messages, Fleet Coin, and Ether to any 3D coordinate in the physical world.

If you just want to try it out, the minimum hardware setup is a Unix-based computer (Linux or Mac computer) and a USB GPS module which outputs NMEA-formatted GPS data via serial.

## Quickstart 

### The Easy Way
Purchasing the [Fleet Fox receiver kit](https://fleetfox.nyc3.digitaloceanspaces.com/diy_instructions/fox.png) is the easiest and fastest way to start using Fleet Fox.

### The Hard Way
If you are tech savvy or are committed to investing the time necessary to acquire the skills you'll need to pilot this early technology, these instructions will bring you up to speed. These steps only apply if you are building your own receiver or running Fleet Fox on a laptop. The Fleet Fox receiver kit comes ready-to-use on powering it on.

### Download and Install the Go Ethereum client 
Fleet Fox requires the Go Ethereum client (geth) to be running in the background. The client is packaged with this repository (geth_arm7 and geth_macOS), and their MD5 checksums can be [found on the Ethereum Foundation's website](https://geth.ethereum.org/downloads).

If you're using a Mac, run:
```
./load_mainnet_macOS.sh
```

On a Raspberry Pi, run:
```
./load_mainnet_rpi.sh
```

Depending on your internet connection, the Ethereum client will take minutes to hours to download the blockchain state. The blockchain must be synchronized before Fleet Fox can interface with it.

```
cd ~/Desktop/fleetfox/simbel
python3
from bcinterface import *

>>> bci = BCInterface(mainnet=True, mac=False)
bci.load_contract()
bci.howdyho()  # sanity check
```
### Managing Ethereum accounts
By default, Simbel uses the zero-indexed Ethereum account. You can specify a different account and unlock accounts.
```
bci.set_account(1)  # use Ethereum account with index of 1 (i.e. second account)
bci.unlock_account()
```

### Create a new account
```
bci.new_account()
```

### Transaction costs
All transactions on the blockchain consume a variable amount of Ether depending on the complexity of the transaction.  To set the amount of gas to send with a transaction:

```
bci.set_gas(...)  # replace ... with the new gas amount
```

### Create a new checkpoint

```
bci.contract.transact(bci.tx).new_checkpoint()

Arguments:
    bytes32 _location_hash,  # output of keccak256(location_string, secret) 
    string description,
    uint ping_ether_amount,  # amount of Ether it costs to ping this checkpoint
    uint ping_token_amaount, # amount of token it costs to ping this checkpoint
    uint ping_token_reward, # token reward for pinging this checkpoint
    uint ping_ether_reward, # Ether reward for pinging this checkpoint

Returns:
    bool success

Example:
    from bcmutil import *
    util = BCMUtil()
    location_hash = util.gen_location_hash(longitude,latitude,altitude,accuracy,secret)  # accuracy is the number of decimal places of accuracy for longitude and latitude; longitude, latitude, and altitude are strings
    bci.contract.transact(bci.tx).new_checkpoint(location_hash, "description of top secret location", 0, 0, 1, 0)

```

### Ping contract with a location
```
bci.contract.transact(bci.tx).ping_checkpoint()

Arguments:
    address owner,
    uint index,
    string location,  # in the form 'longitude,latitude,altitude'
    string secret, 

Returns:
    bytes32 location_hash
```

### Get checkpoint information
```
bci.contract.call().get_checkpoint_status()

Arguments:

    address owner,
    uint index

Returns:
    bytes32 location_hash,
    string description,
    uint ping_ether_cost, 
    uint ping_token_cost,
    uint ping_token_reward,
    uint ping_ether_reward,
    CheckpointState state  # 0: OFF, 1: ON

```
Check Ether and Fleet Coin token balances.
```
bci.contract.call().get_eth_balance("0x...")
bci.contract.call().get_token_balance("0x...")
```


Buy and sell Fleet Coin.
```
bci.tx['value'] = 10**18  # exchange one Ether (10**18 wei = 1 Ether) for Fleet Coin at current exchange rate (1 Ether = 1000 Fleet Coin)
bci.contract.transact(bci.tx).buy()
bci.contract.transact(bci.tx).sell(1000)  # sell 500 fleetcoin at current exchange rate (1 Ether = 1000 Fleet Coin)
```
The Fleet Coin ABI and contract are located in the source directory and can be directly inspected at address 0xe18FE4Ded62a8aa723D6BE485B355d39d409354d on the Ethereum main network.

```
totalSupply: 10,000,000
tokenName: fleetcoin
tokenSymbol: fc
```

There are 10,000,000 Fleet Coin in circulation, which can be exchanged for Ether at a rate of 1,000 Fleet Coin per 1 Ether.


### Running the Fleet Fox client
The minimum hardware necessary is a Unix-based computer connected to a USB GPS module outputting NMEA sentences. The Ethereum account must be manually unlocked, or a password can be provided at the top of fleetfox.py under ACCOUNT_PASSWORD.

To start the Fleet Fox client:
```
sudo python3 fleetfox.py
```

## Deploying on a private network
The following steps are for users with a solid grasp of Ethereum development and networking, or who are motivated to put in the effort to learn. The average user need not deploy the Fleet Coin contract on a private network and can interact with the Fleet Fox contract on the main network. 

To run Fleet Fox on a private network, first run ```deploy.sh``` to compile the Fleet Coin contract and generate the deployment script.
```
cd /home/omar/Desktop/fleetfox
./deploy.sh

Example contructor arguments: 10000000, "fleetcoin", "fc"

```
* Note: * You may need to increase the gas value specified in ```/home/omar/Desktop/fleetfox/simbel/source/fleetcoin.js``` to get the contract mined, depending on how your private network is configured.

Then start the private blockchain.
```
./load_privnet.sh
```
Unlock your Ethereum account and deploy the contract.
```
tmux a -t geth

personal.unlockAccount(eth.accounts[0])
loadScript('/home/omar/Desktop/fleetfox/simbel/source/fleetcoin.js')
```

Make note of the address to which the contract is mined, and update bcinterface.py as necessary.


## Directory structure
The directory structure is important because Simbel and the Simbel Networking Utility look for certain files in certain directories. Your application will look something like this:
```
/your_working_directory
	README.md
	install.sh
	snu.sh
	deploy.sh
	log_nodeInfo.sh
	load_mainnet.sh
	load_privnet.sh 

	/simbel
		crypto.py
		genesis.json
		bcinterface.py
		fsinterface.py
		ipfs.py
		main.py
		nodeInfo.ds
		log_gps.py
		display_map.py
		get_gps_trace.sh
		
		/source
			/data
			static-nodes.json
		/share
		/data
		/messages
		/safari

	/docs
	/images

```
The ```safari``` directory is the default location for .ffx files, and the ```messages``` directory is the default location where messages are downloaded from the blockchain.

## Contribute
Please take a look at the [contribution documentation](https://github.com/simbel/simbel/blob/master/docs/CONTRIBUTING.md) for information on how to report bugs, suggest enhancements, and contribute code. If you or your organization use Fleet Fox to do something great, please share your experience! 

## Code of conduct
In the interest of fostering an open and welcoming environment, we as contributors and maintainers pledge to making participation in our project and our community a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation. Read the full [Contributor Covenant](https://github.com/osmode/fleetfox/blob/master/docs/CODE_OF_CONDUCT.md). 

## Acknowledgements
This project builds on work by the [Ethereum](https://www.ethereum.org), [web3.py](https://github.com/pipermerriam/web3.py), [IPFS](https://github.com/ipfs/ipfs) and [py-ipfs](https://github.com/ipfs/py-ipfs-api) communities. 

## License
[Analog Labs License](https://github.com/simbel/simbel/blob/master/LICENSE) 

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

This work, and all derivatives of this work, must remain in the public domain.

Authors of commercial derivatives and applications of this work must offer to all members of the public the opportunity for stakeholdership in said works, in an equal and fair manner, in the form of ERC20-based token(s).

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

