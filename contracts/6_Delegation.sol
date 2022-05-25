// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Delegation 
/// @author openZeppelin
/// @notice Attack the contract by running sendTransaction({}), pass in from, to, and data(ex. the bytes4(sha3("pwn()")) == 0xdd365b8b0000000000000000000000000000000000000000000000000000000000000000), 
///         The use of delegatecall can be very risky, the contract is practically saying that the delegates have complete access to your contract's state, should be used with extreme care.
///
contract Delegate {

  address public owner;

  constructor(address _owner){
    owner = _owner;
  }

  function pwn() public {
    owner = msg.sender;
  }
}

contract Delegation {

  address public owner;
  Delegate delegate;

  constructor(address _delegateAddress){
    delegate = Delegate(_delegateAddress);
    owner = msg.sender;
  }

  fallback() external {
    (bool result,) = address(delegate).delegatecall(msg.data);
    if (result) {
      this;
    }
  }
}