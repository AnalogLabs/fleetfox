pragma solidity ^0.4.0;

contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}


interface tokenRecipient { function receiveApproval(address _from, uint256
_value, address _token, bytes _extraData) public; }


contract TokenERC20 {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public token_balance;  // NFO coin token balance on main net
    mapping (address => uint256)  public eth_balance;   // associates Ethereum deposited on main net with main net addrress
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of
the contract
     */
    constructor (
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public payable {
// Update total supply with the decimal amount
totalSupply = initialSupply * 10 ** uint256(decimals);

// Give the creator all initial tokens
token_balance[msg.sender] = totalSupply;

// initialize Ether balance of NFO Coin contract
eth_balance[msg.sender] = msg.value;
// Set the name for display purposes

name = tokenName;
// Set the symbol for display purposes
symbol = tokenSymbol;
}

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer_token(address _from, address _to, uint _value)
internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(token_balance[_from] >= _value);
        // Check for overflows
        require(token_balance[_to] + _value > token_balance[_to]);
        // Save this for an assertion in the future
        uint previousBalances = token_balance[_from] + token_balance[_to];
        // Subtract from the sender
        token_balance[_from] -= _value;
        // Add the same to the recipient
        token_balance[_to] += _value;
        Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(token_balance[_from] + token_balance[_to] ==
previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer_token(address _to, uint256 _value) public {
        _transfer_token(msg.sender, _to, _value);
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer_token_from(address _from, address _to, uint256
_value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer_token(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your
behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens in your
behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved
contract
     */

    

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(token_balance[msg.sender] >= _value);   // Check if the sender has enough
        token_balance[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of
`_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool
success) {
        require(token_balance[_from] >= _value);                // Check if  the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        token_balance[_from] -= _value;                         // Subtractvfrom the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }
}

/******************************************/
/*       ADVANCED TOKEN STARTS HERE       */
/******************************************/

contract fleetcoin is owned, TokenERC20 {


        /* This generates a public event on the blockchain that will notify clients */
        event FrozenFunds(address target, bool frozen);

        uint master_exchange_rate;
        string[5] greetings;
        
        
    /* Initializes contract with initial supply tokens to the creator of
the contract */
    constructor (
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public payable  {

        master_exchange_rate = 1000;                        // 1 ETH = 1000 FC

        greetings[0] = "Hi, my name is Omar Metwally.";
        greetings[1] = "I am the creator of this contract.";
        greetings[3] = "Chillin' in Mendocino...";
        greetings[2] = "Chillin' in Portland...";
        greetings[4] = "Chillin' in Seattle...!";
        greetings[4] = "Chillin' in Vancouver...!";        
    }    
    
    mapping(address => TripStruct) public trips;
        address[] public driverList;       
        mapping (address => bool) frozenAccount;

        struct TripStruct {

            address driver;
	    string location;
            TripState state;
            string pickup;
            string dropoff;
	    string altitude;
	    string velocity;
            uint timestamp;
            string description;
        }

        enum TripState { READY, INPROGRESS, ERROR }
        
        // create event on blockchain with each GPS ping 
        event UpdateLocation (address _driver, string _location, TripState _state, string _pickup, string _dropoff, string _altitude, string _velocity, uint _timestamp);
    
function get_trip_status(address driverAddress) public constant
returns(TripState state) {
return trips[driverAddress].state;
   }

function get_my_status() public constant returns(TripState state) {
    return trips[msg.sender].state;
}

function get_status(address driver) public returns(TripState _state, string _location, string _pickup, string _dropoff, string _altitude, string _velocity, uint _timestamp, string _description) {
    require( token_balance[msg.sender] > 100 );
    
    token_balance[msg.sender] -= 1;
    
    _state = trips[driver].state;
    _location = trips[driver].location;
    _pickup = trips[driver].pickup;
    _dropoff = trips[driver].dropoff;
    _altitude = trips[driver].altitude;
    _velocity = trips[driver].velocity;
    _timestamp = trips[driver].timestamp;
    _description = trips[driver].description;
    
}

function get_driver_count() public constant returns(uint driverCount) {
return driverList.length;
}

    function update_status(string location, TripState new_state, string altitude, string velocity, uint timestamp, string description) public {

        // order of these if statements is important - to avoid one
        // true statement triggering a cascade of true statements
	TripState current_state = trips[msg.sender].state;

	// register pickup event
	if (current_state == TripState.READY && new_state == TripState.INPROGRESS) {
		trips[msg.sender].driver = msg.sender;
		trips[msg.sender].location = location;
		trips[msg.sender].state = new_state;
		trips[msg.sender].pickup = location;
		trips[msg.sender].altitude = altitude;
		trips[msg.sender].velocity = velocity;
		trips[msg.sender].timestamp = timestamp;
		trips[msg.sender].description = description;
	
	}

	// update blockchain with current location
	if (current_state == TripState.INPROGRESS && new_state == TripState.INPROGRESS) {
		trips[msg.sender].driver = msg.sender;
		trips[msg.sender].location = location;
		trips[msg.sender].state = new_state;
		trips[msg.sender].altitude = altitude;
		trips[msg.sender].velocity = velocity;
		trips[msg.sender].timestamp = timestamp;
		
	}

	// register dropoff event
	if (current_state == TripState.INPROGRESS && new_state == TripState.READY) {
		trips[msg.sender].driver = msg.sender;
		trips[msg.sender].location = location;
		trips[msg.sender].state = new_state;
		trips[msg.sender].dropoff = location;
		trips[msg.sender].altitude = altitude;
		trips[msg.sender].velocity = velocity;
		trips[msg.sender].timestamp = timestamp;

	}

   }

    function get_eth_balance(address eth_addr) public constant returns
(uint balance) {
        return eth_balance[eth_addr];
    }

    function get_token_balance(address eth_addr) public constant returns
(uint balance) {
        return token_balance[eth_addr];
    }

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require (token_balance[_from] >= _value);               // Check if the sender has enough
        require (token_balance[_to] + _value > token_balance[_to]); // Check for overflows
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        token_balance[_from] -= _value;                         // Subtract from the sender
        token_balance[_to] += _value;                           // Add the same to the recipient
        Transfer(_from, _to, _value);
    }

    /// @notice Create `mintedAmount` tokens and send it to `target`
    /// @param target Address to receive the tokens
    /// @param mintedAmount the amount of tokens it will receive
    function mintToken(address target, uint256 mintedAmount) onlyOwner
public {
        token_balance[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
    }

    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    /// @notice Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
    /// @param newSellPrice Price the users can sell to the contract
    /// @param newBuyPrice Price users can buy from the contract
    /*
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner
public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }
    */

    /// @notice Buy tokens from contract by sending ether
    function buy() payable public {
        uint amount = msg.value * master_exchange_rate;  // buyPrice;
        // calculates the amount
        _transfer(owner, msg.sender, amount);
  // makes the transfers
        eth_balance[msg.sender] += msg.value;
 // update eth_balance
        token_balance[msg.sender] += amount;  // update token_balance
    }

    /// @notice Sell `amount` tokens to contract
    /// @param amount amount of tokens to be sold
    function sell(uint256 amount) public {
        require(eth_balance[this] >= (amount / master_exchange_rate) );      // checks if the contract has enough ether to buy
        _transfer(msg.sender, owner, amount);              // makes the transfers
        msg.sender.transfer(amount / master_exchange_rate);          // sends ether to the seller. It's important to do this last to avoid recursion attacks
        token_balance[msg.sender] -= amount;   // update token_balance
        eth_balance[msg.sender] -= (amount/master_exchange_rate) ;   // update eth_balance
    }

    /* Generates a random number from 0 to 10 based on the last block hash
*/
    function randomGen(uint seed) public constant returns (uint
randomNumber) {
        return(uint(sha3(block.blockhash(block.number-1), seed ))%10);
    }

    function get_driver_by_row(uint row) public constant returns (address _driver, string _location, TripState _state, string _pickup, string _dropoff,
	string _altitude, string _velocity, uint _timestamp)
{

        require(row<driverList.length);
        require(row>=0);
       
        _driver = driverList[row];
        _location = trips[driverList[row]].location; 
        _state = trips[driverList[row]].state;
        _pickup = trips[driverList[row]].pickup;
        _dropoff = trips[driverList[row]].dropoff;
	_altitude = trips[driverList[row]].altitude;
	_velocity = trips[driverList[row]].velocity;
        _timestamp = trips[driverList[row]].timestamp;
    }

    function set_master_exchange_rate(uint new_rate) public  returns (uint
exchange_rate) {
        require(msg.sender == owner);
        master_exchange_rate = new_rate;
        return master_exchange_rate;
    }
    function greet_omar(uint _i) public constant returns (string greeting) {
        require(_i>=0);
        require(_i<greetings.length);
        return greetings[_i];
    }
}

