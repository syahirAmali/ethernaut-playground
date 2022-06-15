// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title AlienCodex - https://coder-question.com/cq-blog/525391 / https://www.youtube.com/watch?v=oGx-EvSsQbE&ab_channel=D-Squared
/// @author OpenZeppelin
/// @notice - There is an underflow weakness
///         - No CEI, Check,  Effect, Interact https://ethereum-solidity.readthedocs.io/en/latest/security-considerations.html#use-the-checks-effects-interactions-pattern
///         - Theres no check for an underflow for the dynamic array https://docs.soliditylang.org/en/v0.6.2/miscellaneous.html#layout-of-state-variables-in-storage
///         - If something is 32 bytes, then there is 256 bits
///         - this means that for example a bytes32 will take up an entire memory slot, also applies for uint256 which means 256 bits
///         - theres something known as 0 padding which, takes up the entire slot eventhough the data isnt that long, this is because of the data type
///         - address is 20 bytes and bool is 1 byte
///         - ABI encoding, doesnt validate length with the payload, 
///         - Steps
///         - 1. make contact -> change contacted to true
///         - 2. retract, so that it underflows, and we have full control of the codex array
///         - 3. find the position of the owner index
///         - 4. call revise with the index and our address, will be 0 padded out to go over abi weakness
///         - Find the location of the owner by, using the keccak256 hashing to find the starting position(always full stack slot - 32 bytes)
///         - Formula is keccak256(k.p) *concatenated*
///         - p = position in the smart contract storage slot, storing the array
///         - k = value corresponding with the array
///         - p = await web3.utils.keccak256(web3.eth.abi.encodeParameters(['uint256'], [1])) 
///         - slot 1 is where length.array is defined
///         - i= BigInt(2 ** 256) - BigInt(p) , this is where the owner is located in the 0 slot in th array
///         - content = '0x' + '0'.repeat(24) + player.slice(2)
///         - pad the address with 0s
///         - finally, await contract.revise(i, content)

///         This level exploits the fact that the EVM doesn't validate an array's ABI-encoded length vs its actual payload.
///         Additionally, it exploits the arithmetic underflow of array length, by expanding the array's bounds to the entire storage area of 2^256. The user is then able to modify all contract storage.
///         Both vulnerabilities are inspired by 2017's - https://medium.com/@weka/announcing-the-winners-of-the-first-underhanded-solidity-coding-contest-282563a87079
// import '../helpers/Ownable-05.sol';

// contract AlienCodex is Ownable {

//   bool public contact;
//   bytes32[] public codex; <---- dynamic array

//   modifier contacted() {
//     assert(contact);
//     _;
//   }
  
//   function make_contact() public {
//     contact = true;
//   }

//   function record(bytes32 _content) contacted public {
//   	codex.push(_content);
//   }

//   function retract() contacted public {
//     codex.length--;
//   }

//   function revise(uint i, bytes32 _content) contacted public {
//     codex[i] = _content;
//   }
// }