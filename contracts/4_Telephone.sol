// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Telephone
/// @author OpenZeppelin
/// @notice tx.origin and msg.sender shouldnt be confused with, they can be used to perform phishing style attacks
///         the example below shows a very surface level example of the vulnerability

contract Telephone {

  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}