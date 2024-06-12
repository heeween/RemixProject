// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IERC20.sol";

contract CSAMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function _mint(address _to, uint256 amount) private {
        balanceOf[_to] += amount;
        totalSupply += amount;
    }

    function _burn(address _from, uint256 amount) private {
        balanceOf[_from] -= amount;
        totalSupply -= amount;
    }

    function _update(uint256 _res0, uint256 _res1) private {
        reserve0 = _res0;
        reserve1 = _res1;
    }

    function swap(address _tokenIn, uint256 _amountIn)
        external
        returns (uint256 amountOut)
    {
        require(
            _tokenIn == address(token0) || _tokenIn == address(token1),
            "Invalid token"
        );
        bool isToken0 = _tokenIn == address(token0);
        (
            IERC20 tokenIn,
            IERC20 tokenOut,
            uint256 reserveIn,
            uint256 reserveOut
        ) = isToken0
                ? (token0, token1, reserve0, reserve1)
                : (token1, token0, reserve1, reserve0);
        // transfer tokenIn
        uint256 amountIn;
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);
        amountIn = tokenIn.balanceOf(address(this)) - reserveIn;
        // calculate amount out (including fees)
        amountOut = (amountIn * 997) / 1000;
        // update reserve variables
        _update(reserveIn + _amountIn, reserveOut - amountOut);
        // transer token out
        tokenOut.transfer(msg.sender, amountOut);
    }

    function addLiquidity(uint256 _amount0, uint256 _amount1)
        external
        returns (uint256 shares)
    {
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);
        uint bal0 = token0.balanceOf(address(this));
        uint bal1 = token1.balanceOf(address(this));

        uint d0 = bal0 - reserve0;
        uint d1 = bal1 - reserve1;
        if (totalSupply == 0) {
            shares = d0 + d1;
        }else {
            shares = ((d0 + d1) * totalSupply) / (reserve0 + reserve1);
        }
        require(shares > 0, "shares = 0");
        _mint(msg.sender, shares);

        _update(bal0, bal1);
    }

    function removeLiquidity(uint _shares) external returns(uint d0,uint d1){
        d0 = (reserve0 * _shares) / totalSupply;
        d1 = (reserve1 * _shares) / totalSupply;
        _burn(msg.sender, _shares);
        _update(reserve0 - d0, reserve1 - d1);
        if (d0 > 0) {
            token0.transfer(msg.sender, d0);
        }
        if (d1 > 0) {
            token1.transfer(msg.sender, d1);
        }
    }
}
