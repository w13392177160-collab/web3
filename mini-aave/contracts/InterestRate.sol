// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract interestRate {
    // base 2% + utilizationRate * 10%
    function borrowRate(uint256 utilizationRate) external pure returns (uint256) {
        return 2e16 + (utilizationRate * 10e16) / 1e18;
    }
}