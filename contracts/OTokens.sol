// SPDX-License-Identifier: MIT

pragma solidity >=0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OToken is ERC20 {
    uint private _totalSupply;
    constructor(string memory  n, string memory s, uint8 dec, uint256 supply) ERC20(n, s) {
        _totalSupply = supply * 10 ** 18;
        _mint(msg.sender, _totalSupply);
    }
}