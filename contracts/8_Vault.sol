// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Vault
/// @author openZeppelin
/// @notice Everything in the blockchain can be retrieved
///         Private only prevents other contracts from accessing it, variables marked as private and local can still be publicly accessed
///         to ensure data is private, it should be encrypted before being put onto the blockchain
///         in this case the decryption key should not be sent on-chain

contract Vault {
  bool public locked;
  bytes32 private password;

  constructor(bytes32 _password){
    locked = true;
    password = _password;
  }

  function unlock(bytes32 _password) public {
    if (password == _password) {
      locked = false;
    }
  }
}