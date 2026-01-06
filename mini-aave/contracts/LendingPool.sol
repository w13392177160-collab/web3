// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IERC20.sol";
import "./interfaces/IPriceOracle.sol";

contract LendingPool{
   
   uint256 public constant LTV = 75;
   uint256 public constant LIQ_THRESHOLD = 80;

   IPriceOracle public oracle;

   mapping(address => mapping(address => uint256)) public deposit;
   mapping(address => mapping(address => uint256)) public borrows;

  constructor(address _oracle){
     oracle = IPriceOracle(_oracle);
  }

  function deposit(address token,uint256 amount) external{
     IERC20(token).transferFrom(msg.sender,address(this),amount);
     deposit[msg.sender][token] += amount;
  }

 function borrow(address token,uint256 amount) external{
    uint256 collateral = deposit[msg.sender][token];
    uint256 price = oracle.getPrice(token);
    uint256 collateralValue = (collateral * price) / 1e18;
    uint256 maxBorrow = (collateralValue * LTV) / 100;
    require(amount <= maxBorrow,"Exceeds max borrow limit");
    borrows[msg.sender][token] += amount;
    IERC20(token).transfer(msg.sender,amount);
  }

  function repay(address token,uint256 amount) external{
   IERC20(token).transferFrom(msg.sender,address(this),amount);
   borrows[msg.sender][token] -= amount;
  }

  function healthFactor(address user,address token) public view returns (uint256){
   uint256 pirce = oracle.getPrice(token);
   uint256 collateralValue = deposit[user][token] * price / 1e18;
   uint256 debtValue = borrows[user][token] * price / 1e18;

   if(debtValue == 0) return type(uint256).max;
   return collateralValue * LIQ_THRESHOLD * 1e18 / (debtValue * 100);
  }

}