// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LendingPool.sol";
import "./interface/IERC20.sol";

contract Liquidation{
    uint256 public constant BONUS = 5; // 5%

    function Liquidate(LendingPool pool,address user,address token,uint256 repayAmount) external{
        uint256 hf = pool.healthFactor(user,token);
        require(hf < 1e18,"HEALTHY");

        IERC20(token).transferFrom(msg.sender,address(pool),repayAmount);

        uint256 seize = repayAmount * (100 + BONUS) / 100;
        pool.repay(token,repayAmount);
        IERC20(token).transfer(msg.sender,seize);
    
    }

}