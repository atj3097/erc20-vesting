// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract VestingToken is ERC20 {
    constructor() ERC20("VestingToken", "VTK") {
        _mint(msg.sender, 1000000000000000000000000000);
    }
}