
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint amount) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function balanceOf(address account) external view returns (uint);
}

contract UniswapPair {
    address public token0;
    address public token1;

    uint public reserve0;
    uint public reserve1;

    event LiquidityAdded(address indexed provider, uint amount0, uint amount1);
    event Swap(address indexed user, address indexed fromToken, uint amountIn, address indexed toToken, uint amountOut);

    constructor(address _token0, address _token1) {
        require(_token0 != address(0) && _token1 != address(0), "Zero address");
        require(_token0 != _token1, "Same token");
        token0 = _token0;
        token1 = _token1;
    }

    function addLiquidity(uint amount0, uint amount1) external {
        require(amount0 > 0 && amount1 > 0, "Zero amount");
        require(IERC20(token0).transferFrom(msg.sender, address(this), amount0), "Transfer token0 failed");
        require(IERC20(token1).transferFrom(msg.sender, address(this), amount1), "Transfer token1 failed");
        reserve0 += amount0;
        reserve1 += amount1;
        emit LiquidityAdded(msg.sender, amount0, amount1);
    }

    function swap(address fromToken, uint amountIn, uint minAmountOut) external {
        require(fromToken == token0 || fromToken == token1, "invalid token");
        require(amountIn > 0, "Zero amount");
        bool isToken0In = fromToken == token0;
        (address input, address output, uint reserveIn, uint reserveOut) = isToken0In
            ? (token0, token1, reserve0, reserve1)
            : (token1, token0, reserve1, reserve0);

        require(IERC20(input).transferFrom(msg.sender, address(this), amountIn), "Transfer in failed");

        // 0.3% fee
        uint amountInWithFee = amountIn * 997 / 1000;
        uint amountOut = (amountInWithFee * reserveOut) / (reserveIn + amountInWithFee);
        require(amountOut >= minAmountOut, "Slippage: insufficient output");
        require(amountOut > 0 && amountOut <= reserveOut, "Insufficient liquidity");

        require(IERC20(output).transfer(msg.sender, amountOut), "Transfer out failed");

        if (isToken0In) {
            reserve0 += amountIn;
            reserve1 -= amountOut;
        } else {
            reserve1 += amountIn;
            reserve0 -= amountOut;
        }

        emit Swap(msg.sender, input, amountIn, output, amountOut);
    }
}
