// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/// @title Fallback solidity
/// @author OpenZeppelin
/// @notice - you claim ownership of the contract
///         - you reduce its balance to 0
///         Tips
///         - How to send ether when interacting with an ABI
///         - How to send ether outside of the ABI
///         - Converting to and from wei/ether units (see help() command)
///         - Fallback methods

///         Solution
///         - Use the contribute function and send more than the owner's contribution which is 1000 ether
///         - Use the fallback function by sending ether to the contract and not include anything in the data field since receive needs to be triggered

contract Fallback {

  using SafeMath for uint256;
  mapping(address => uint) public contributions;
  address payable public owner;

  constructor() public {
    owner = payable(msg.sender);
    contributions[msg.sender] = 1000 * (1 ether);
  }

  modifier onlyOwner {
        require(
            msg.sender == owner,
            "caller is not the owner"
        );
        _;
    }

  function contribute() public payable {
    require(msg.value < 0.001 ether);
    contributions[msg.sender] += msg.value;
    if(contributions[msg.sender] > contributions[owner]) {
      owner = payable(msg.sender);
    }
  }

  function getContribution() public view returns (uint) {
    return contributions[msg.sender];
  }

  function withdraw() public onlyOwner {
    owner.transfer(address(this).balance);
  }

  receive() external payable {
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = payable(msg.sender);
  }
}