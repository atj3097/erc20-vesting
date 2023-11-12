// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/VestingToken.sol";
import "../src/VestingContract.sol";

contract Deploy is Script {
    function run() external {
        // Deploy VestingToken
        vm.startBroadcast();
        VestingToken vestingToken = new VestingToken();
        vm.stopBroadcast();
        console.log("VestingToken deployed to:", address(vestingToken));

        // Deploy VestingContract
        uint256 totalVestingMonths = 12; // Example value, adjust as needed
        address companyAddress = msg.sender; // Replace with your address
        vm.startBroadcast();
        VestingContract vestingContract = new VestingContract(address(vestingToken), totalVestingMonths, companyAddress);
        vm.stopBroadcast();
        console.log("VestingContract deployed to:", address(vestingContract));
    }
}
