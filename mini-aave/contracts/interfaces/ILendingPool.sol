// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILendingPool{
    function deposit(address token,uint256 amount) external;
    function borrow(address token,uint256 amount) external;
    function repay(address token,uint256 amount) external;
}