// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";

contract Pair{
    address public token0;
    address public token1;

    uint112 private reserve0;
    uint112 private reserve1;

    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }

    function getReserves() external view returns (uint112, uint112) {
        return (reserve0, reserve1);
    }

    function _update(uint balance0, uint balance1) private {
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
    }

    function mint(address to) external returns (uint liquidity) {
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        uint amount0 = balance0 - reserve0;
        uint amount1 = balance1 - reserve1;

        if (totalSupply == 0) {
            liquidity = sqrt(amount0 * amount1);
        } else {
            liquidity = min((amount0 * totalSupply) / reserve0, (amount1 * totalSupply) / reserve1);
        }

        require(liquidity > 0, "Insufficient liquidity minted");
        totalSupply += liquidity;
        balanceOf[to] += liquidity;

        _update(balance0, balance1);
    }

    function burn(address to) external returns (uint amount0, uint amount1) {
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));

        uint liquidity = balanceOf[address(this)];

        amount0 = (liquidity * balance0) / totalSupply;
        amount1 = (liquidity * balance1) / totalSupply;

        require(amount0 > 0 && amount1 > 0, "Insufficient liquidity burned");

        balanceOf[address(this)] = 0;
        totalSupply -= liquidity;

        IERC20(token0).transfer(to, amount0);
        IERC20(token1).transfer(to, amount1);

        balance0 = IERC20(token0).balanceOf(address(this));
        balance1 = IERC20(token1).balanceOf(address(this));

        _update(balance0, balance1);
    }

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to
    ) external {
        require(amount0Out > 0 || amount1Out > 0, "Insufficient output amount");

        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));

        require(amount0Out < balance0 && amount1Out < balance1, "Insufficient liquidity");

        if (amount0Out > 0) {
            IERC20(token0).transfer(to, amount0Out);
        }
        if (amount1Out > 0) {
            IERC20(token1).transfer(to, amount1Out);
        }

        uint balance0After = IERC20(token0).balanceOf(address(this));
        uint balance1After = IERC20(token1).balanceOf(address(this));

        require(
            (balance0After * balance1After) >= (balance0 * balance1),
            "K invariant violation"
        );

        _update(balance0After, balance1After);
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function min(uint x, uint y) internal pure returns (uint) {
        return x < y ? x : y;
    }



}

