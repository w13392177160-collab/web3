// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IPair.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/IERC20.sol";

contract Router {
    address public factory;

    constructor(address _factory) {
        factory = _factory;
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired
    ) external returns (uint liquidity) {
        address pair = IFactory(factory).getPair(tokenA, tokenB);
        if (pair == address(0)) {
            pair = IFactory(factory).createPair(tokenA, tokenB);
        }

        IERC20(tokenA).transferFrom(msg.sender, pair, amountADesired);
        IERC20(tokenB).transferFrom(msg.sender, pair, amountBDesired);

        liquidity = IPair(pair).mint(msg.sender);
    }

   function swapExactTokensForTokens(
       uint amountIn,
       uint amountOutMin,
       address tokenIn,
       address tokenOut,
       address to
   ) external {
       address pair = IFactory(factory).getPair(tokenIn, tokenOut);
       require(pair != address(0), "Pair does not exist");

       IERC20(tokenIn).transferFrom(msg.sender, pair, amountIn);

       (uint112 reserve0, uint112 reserve1) = IPair(pair).getReserves();
       (address token0,) = tokenIn < tokenOut ? (tokenIn, tokenOut) : (tokenOut, tokenIn);
       (uint112 reserveIn, uint112 reserveOut) = tokenIn == token0 ? (reserve0, reserve1) : (reserve1, reserve0);

       uint amountInWithFee = amountIn * 997;
       uint numerator = amountInWithFee * reserveOut;
       uint denominator = (reserveIn * 1000) + amountInWithFee;
       uint amountOut = numerator / denominator;

       require(amountOut >= amountOutMin, "Insufficient output amount");

       (uint amount0Out, uint amount1Out) = tokenIn == token0 ? (uint(0), amountOut) : (amountOut, uint(0));

       IPair(pair).swap(amount0Out, amount1Out, to);
   }

}