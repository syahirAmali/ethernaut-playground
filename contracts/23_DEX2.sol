// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Dex2
/// @author OpenZeppelin
/// @notice - The Vulnerability comes from the fact that the swap does not check for a swap between token 1 and token 2
///         - So this means that any token can be swapped freely 
///         - Solution =- create your own token and use that to saw and drain both token1 and token2
///         - Steps to attack =-
///         - Create your own attack token
///         - mint 300 tokens
///         - Approve the tokens and contract
///         - You will need to add liquidity before proceeding since it will cause an error if there are no tokens in the pool, since the formula for the price wont work
///         - since add liquidity is only for owner, you can transfer the the contract 100 token from your side
///         - swap all 100 attack token with token1, the current price ratio is 1:1 so you will be able to drain it
///         - then swap 200 attack token with token2, you will need to swap 200 because of the updated price
///         - more detailed explanation can be found here, https://dev.to/nvn/ethernaut-hacks-level-23-dex-two-4424

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract DexTwo is Ownable {
  using SafeMath for uint;
  address public token1;
  address public token2;
  constructor() public {}

  function setTokens(address _token1, address _token2) public onlyOwner {
    token1 = _token1;
    token2 = _token2;
  }

  function add_liquidity(address token_address, uint amount) public onlyOwner {
    IERC20(token_address).transferFrom(msg.sender, address(this), amount);
  }
  
  function swap(address from, address to, uint amount) public {
    require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
    uint swapAmount = getSwapAmount(from, to, amount);
    IERC20(from).transferFrom(msg.sender, address(this), amount);
    IERC20(to).approve(address(this), swapAmount);
    IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
  } 

  function getSwapAmount(address from, address to, uint amount) public view returns(uint){
    return((amount * IERC20(to).balanceOf(address(this)))/IERC20(from).balanceOf(address(this)));
  }

  function approve(address spender, uint amount) public {
    SwappableTokenTwo(token1).approve(msg.sender, spender, amount);
    SwappableTokenTwo(token2).approve(msg.sender, spender, amount);
  }

  function balanceOf(address token, address account) public view returns (uint){
    return IERC20(token).balanceOf(account);
  }
}

contract SwappableTokenTwo is ERC20 {
  address private _dex;
  constructor(address dexInstance, string memory name, string memory symbol, uint initialSupply) public ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
  }

  function approve(address owner, address spender, uint256 amount) public returns(bool){
    require(owner != _dex, "InvalidApprover");
    super._approve(owner, spender, amount);
  }
}