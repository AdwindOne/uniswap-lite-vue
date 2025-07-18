
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    uint8 private _customDecimals;
    
    constructor(
        string memory name_, 
        string memory symbol_, 
        uint256 initialSupply,
        uint8 decimals_
    ) ERC20(name_, symbol_) {
        _mint(msg.sender, initialSupply);
        _customDecimals = decimals_;
    }
    
    function decimals() public view virtual override returns (uint8) {
        return _customDecimals;
    }
}
