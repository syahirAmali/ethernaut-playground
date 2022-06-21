// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Shop
/// @author OpenZeppelin
/// @notice - Vulnerability comes from the getSwapPrice
///         - This method determines the exchange rate between the tokens
///         - this result wont always be a perfect intger
///         - And because of how solidity works then there wont be any floating points or fractions
///         - Instead division rounds towards zero
///         - Method of attack
///         - Keep swapping tokens back and forth until one of it is drained
///         - Here for a detailed explanation =- https://dev.to/nvn/ethernaut-hacks-level-22-dex-1e18
///         - After each swap we will get more of token1 or token2 than held before previous swap
///         - This is because of the price inaccuracies that exists in getSwapPrice
///         - 

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Dex is Ownable {
  using SafeMath for uint;
  address public token1;
  address public token2;
  constructor(){}

  function setTokens(address _token1, address _token2) public onlyOwner {
    token1 = _token1;
    token2 = _token2;
  }
  
  function addLiquidity(address token_address, uint amount) public onlyOwner {
    IERC20(token_address).transferFrom(msg.sender, address(this), amount);
  }
  
  function swap(address from, address to, uint amount) public {
    require((from == token1 && to == token2) || (from == token2 && to == token1), "Invalid tokens");
    require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
    uint swapAmount = getSwapPrice(from, to, amount);
    IERC20(from).transferFrom(msg.sender, address(this), amount);
    IERC20(to).approve(address(this), swapAmount);
    IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
  }

  function getSwapPrice(address from, address to, uint amount) public view returns(uint){
    return((amount * IERC20(to).balanceOf(address(this)))/IERC20(from).balanceOf(address(this)));
  }

  function approve(address spender, uint amount) public {
    SwappableToken(token1).approve(msg.sender, spender, amount);
    SwappableToken(token2).approve(msg.sender, spender, amount);
  }

  function balanceOf(address token, address account) public view returns (uint){
    return IERC20(token).balanceOf(account);
  }
}

contract SwappableToken is ERC20 {
  address private _dex;
  constructor(address dexInstance, string memory name, string memory symbol, uint256 initialSupply) public ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
  }

  function approve(address owner, address spender, uint256 amount) public returns(bool){
    require(owner != _dex, "InvalidApprover");
    super._approve(owner, spender, amount);
  }
}

/// The integer math portion aside, getting prices or any sort of data from any single source is a massive attack vector in smart contracts.
/// someone with a lot of capital could manipulate the price in one fell swoop, and cause any applications relying on it to use the the wrong price
/// he price of the asset is centralized, since it comes from 1 dex
/// this is why oracles are necessary, We should be getting our data from multiple independent decentralized sources, otherwise we can run this risk