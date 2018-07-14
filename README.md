# Fleet Fox 
## A collaborative map of planet Earth on the Ethereum blockchain

## What is Fleet Fox?
Fleet Fox is a public ledger of annotated GPS data hosted on the Ethereum blockchain.
 
## Why Fleet Fox?
* Funding model for Emergency Medical Services, especially in under-served geographic areas

* P2P blockchain backend for business-to-consumer fleet sharing services (vehicles, bicycles, electric scooters)

* Blockchain backend for peer-to-peer vehicle sharing services

* Collaborative map-making and location sharing

## Quickstart 
First make sure you have the Go-Ethereum client (aka *geth*) installed on your machine. You can [build it from source](https://github.com/ethereum/go-ethereum) or [download the binary](https://geth.ethereum.org/downloads/).

*1. Blockchain synchronization*

Start the Ethereum client and sync with the Ethereum blockchain.
```
geth --syncmode light console
```

*2. Download Fleet Fox repository*

*3. Interface with the Fleet Fox contract*

The Fleet Coin contract gives the Fleet Fox application its functionality as a ledger of annotated GPS coordinates and fleet management tool.

First make sure the Ethereum client is running in a separate terminal window or in the background.

Once the Ethereum client is running in the background and the blockchain has completed synchronization, you can interface with the contract using the BCInterface class.
```
cd /home/omar/Desktop/fleetfox/
python3
from bcinterface import *

>>> bci = BCInterface(mainnet=True)
bci.load_contract(contract_name="fleetcoin")
bci.howdyho()  # sanity check
```
### Managing Ethereum accounts
By default, the BCInterface class uses the zero-indexed Ethereum account on your machine. You can specify a different account and unlock accounts.
```
bci.set_account(1)  # use Ethereum account with index of 1 (i.e. second account)
bci.unlock_account()
```
Presently, new accounts must be created using the Ethereum client.

*TODO:* enable account creation via Web3

### Query blockchain for a user's trip status.
```
bci.contract.call().get_trip_status("0x...")

    returns TripState (0 = READY, 1 = INPROGRESS, 2 = ERROR),
	    location ( latitude and longitude), 
	    pickup (pickup gps location),
	    dropoff (dropoff gps location),
	    altitude (in meters),
	    velocity (in km/hr),
	    timestamp,
	    description (string associated with gps ping)
````

### Update blockchain with current GPS location and trip status.
```
bci.contract.transact(bci.tx).update_status( ... )

    Arguments:
    ----------
	string location, 
	TripState new_state, 
	string altitude, 
	string velocity, 
	uint timestamp, 
	string description
```

### Check Ether and Fleet Coin token balances.
```
bci.contract.call().get_eth_balance("0x...")
bci.contract.call().get_token_balance("0x...")
```

### Adjust gas amount for blockchain transactions.
```
bci.set_gas(21000)
```

### Buy and sell Fleet Coin.
```
bci.tx['value'] = 1  # exchange one Ether for Fleet Coin at current exchange rate
bci.contract.transact(bci.tx).buy()

bci.contract.transact(bci.tx).sell(500)  # sell 500 fleetcoin
```
The Fleet Coin ABI and contract are located in the source directory and can be directly inspected at address 0x19158FB8696b499C12018A0B69B8B95C9Ce0fA05 on the Ethereum main network.

```
totalSupply: 10,000,000
tokenName: fleetcoin
tokenSymbol: fc
```

There are 10,000,000 Fleet Coin in circulation, which can be exchanged for Ether at a rate of 1,000 Fleet Coin per 1 Ether.



## Deploying on a private network
The following steps are for users with a solid grasp of Ethereum development and networking, or who are motivated to put in the effort to learn. The average user need not deploy the Fleet Coin contract on a private network and can interact with the Fleet Fox contract on the main network. 

[Simbel](https://github.com/osmode/simbel), the Ethereum operating system for knowledge creation and sharing, simplifies contract deployment. To run Fleet Fox on a private network, first run ```deploy.sh``` to compile the Fleet Coin contract and generate the deployment script.
```
cd /home/omar/Desktop/simbel
./deploy.sh

Example contructor arguments: 10000000, "fleetcoin", "fc"

```
**Note:** You may need to increase the gas value specified in ```/home/omar/Desktop/simbel/source/fleetcoin.js``` to get the contract mined, depending on how your private network is configured.

Then start the private blockchain.
```
./load_privnet.sh
```
Open the tmux geth window and unlock your Ethereum account.
```
tmux a -t geth

personal.unlockAccount(eth.accounts[0])
loadScript('/home/omar/Desktop/simbel/source/fleetcoin.js')
```

Make note of the address to which the contract is mined, and update bcinterface.py as necessary.


## Contribute
Please take a look at the [contribution documentation](https://github.com/osmode/fleetfox/blob/master/docs/CONTRIBUTING.md) for information on how to report bugs, suggest enhancements, and contribute code. If you or your organization use Fleet Fox to do something great, please share your experience! 

## Code of conduct
In the interest of fostering an open and welcoming environment, we as contributors and maintainers pledge to making participation in our project and our community a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation. Read the full [Contributor Covenant](https://github.com/osmode/fleetfox/blob/master/docs/CODE_OF_CONDUCT.md). 

## Acknowledgements
This project builds on work by the [Ethereum](https://www.ethereum.org), [web3.py](https://github.com/pipermerriam/web3.py), [IPFS](https://github.com/ipfs/ipfs) and [py-ipfs](https://github.com/ipfs/py-ipfs-api) communities. 

## License
[Analog Labs License](https://github.com/simbel/simbel/blob/master/LICENSE) 

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

This work, and all derivatives of this work, must remain in the public domain.

Authors of commercial derivatives and applications of this work must offer to all members of the public the opportunity for stakeholdership in said works, in an equal and fair manner, in the form of ERC20-based token(s).

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

