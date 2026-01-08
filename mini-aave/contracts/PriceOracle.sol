// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PriceOracle {
    mapping(address => uint256) private prices;

    function setPrice(address asset, uint256 price) external {
        prices[asset] = price;
    }

    function getPrice(address asset) external view returns (uint256) {
        return prices[asset];
    }
}