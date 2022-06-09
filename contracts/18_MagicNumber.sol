// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title GarekeeperOne
/// @author OpenZeppelin
/// @notice - 

import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract MagicNum {

  address public solver;

  constructor(){}

  function setSolver(address _solver) public {
    solver = _solver;
  }
}

contract AttackMagicNumber{
  constructor(){
    assembly {

      // This is the bytecode we want the program to have:
      // 00 PUSH1 2a /* push dec 42 (hex 0x2a) onto the stack */
      // 03 PUSH1  0 /* store 42 at memory position 0 */
      // 05 MSTORE
      // 06 PUSH1 20 /* return 32 bytes in memory */
      // 08 PUSH1 0
      // 10 RETURN
      // Bytecode: 0x604260005260206000f3 (length 0x0a or 10)
      // Bytecode within a 32 byte word:
      // 0x00000000000000000000000000000000000000000000604260005260206000f3 (length 0x20 or 32)
      //                                               ^ (offset 0x16 or 22)
      // 32 because it is the size of a data slot in solidity
      // so to get the data in this slot
      // - first store the data to the stack with mstore
      // which will result in 60426000 which is 60 for the opcode push1, then 42 for the data, then 0 for the memory position
      // - then  once we have the data stored, we will have to return it to pass the test
      // we can use the return opcode to return the data
      // this will result in 60206000f3
      // totally they will be be appended to be 0x604260005260206000f3
      // this means that the data is stored at the slot and returned according to the offset of 0x16 or 20 bytes, then the data length would be 0x0a which is 10bytes

      // 32 - 10 = 22 = 0x16
      mstore(0, 0x602a60005260206000f3)
      return(0x16, 0x0a)
    }
  }
}