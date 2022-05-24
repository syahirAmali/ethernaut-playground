// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Telephone
/// @author OpenZeppelin
/// @notice A typical overflow/underflow problem, **this should throw an error from sol ver 0.8 an above, or safemath library should be used to ensure it doesnt occur

contract Token {

  mapping(address => uint) balances;
  uint public totalSupply;

  constructor(uint _initialSupply) {
    balances[msg.sender] = totalSupply = _initialSupply;
  }

  function transfer(address _to, uint _value) public returns (bool) {
    require(balances[msg.sender] - _value >= 0);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    return true;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}