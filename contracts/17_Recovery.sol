// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title GarekeeperOne
/// @author OpenZeppelin
/// @notice - Contract Addresses are deterministic, and predetermined, it is calculated by keccak256(address, nonce)
///         - address is the address of the contract or the address which created the transaction
///         - nonce is the number of contracts the spawning contract has created (or the transaction nonce, for regular transactions).
///         - one can send ether to a pre-determined address (which has no private key) and later create a contract at that address which recovers the ether. 
///         - This is a non-intuitive and somewhat secretive way to (dangerously) store ether without holding a private key.
///         - If you're going to implement this technique, make sure you don't miss the nonce, or your funds will be lost forever
///         - address = rightmost_20_bytes(keccak(RLP(sender address, nonce)))
///         - From documentation, the RLP encoding of a 20-byte address is: 0xd6, 0x94 . And for all integers less than 0x7f,
///         - its encoding is just its own byte value. So the RLP of 1 is 0x01.
///         - so the output is address public a = address(keccak256(0xd6, 0x94, YOUR_ADDR, 0x01)); ** this should yield your contract address
///         - just increase the nonce to find subsequent contract addresses

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Recovery {

  //generate tokens
  function generateToken(string memory _name, uint256 _initialSupply) public {
    new SimpleToken(_name, msg.sender, _initialSupply);
  
  }
}

contract SimpleToken {

  using SafeMath for uint256;
  // public variables
  string public name;
  mapping (address => uint) public balances;

  // constructor
  constructor(string memory _name, address _creator, uint256 _initialSupply) public {
    name = _name;
    balances[_creator] = _initialSupply;
  }

  // collect ether in return for tokens
  receive() external payable {
    balances[msg.sender] = msg.value.mul(10);
  }

  // allow transfers of tokens
  function transfer(address _to, uint _amount) public { 
    require(balances[msg.sender] >= _amount);
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[_to] = _amount;
  }

  // clean up after ourselves
  function destroy(address payable _to) public {
    selfdestruct(_to);
  }
}

