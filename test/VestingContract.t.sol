//// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import "../../src/VestingToken.sol";
import "../../src/VestingContract.sol";


contract VestingContractTest is Test {

    address[] public fakeEmployees = [
    address(0x1000000000000000000000000000000000000001),
    address(0x2000000000000000000000000000000000000002),
    address(0x3000000000000000000000000000000000000003),
    address(0x4000000000000000000000000000000000000004),
    address(0x5000000000000000000000000000000000000005),
    address(0x6000000000000000000000000000000000000006)
    ];

    VestingToken public companyMockERC20;
    VestingContract vestingContract;

    function setUp() public {
        companyMockERC20 = new VestingToken();

        vestingContract = new VestingContract(address(companyMockERC20), 12, address(this));
        console.log("Employer address:", address(vestingContract.company()));
        console.log("Test address:", address(this));
        IERC20(companyMockERC20).approve(address(vestingContract), 1000000000000);
        IERC20(companyMockERC20).transfer(address(vestingContract), 1000000000000);

        vestingContract.depositTokens(10000000);
        vestingContract.addEmployee(fakeEmployees[0], 1000);
        vestingContract.addEmployee(fakeEmployees[1], 1000);
        vestingContract.addEmployee(fakeEmployees[2], 1000);
        vestingContract.addEmployee(fakeEmployees[3], 1000);
        vestingContract.addEmployee(fakeEmployees[4], 1000);
        vestingContract.addEmployee(fakeEmployees[5], 1000);
    }

    function testInitialSetup() public {
        assertEq(vestingContract.company() == address(this), true);
        assertEq(vestingContract.totalVestingMonths(), 12, "Incorrect total vesting months");
        assertEq(vestingContract.employeeVestingAmounts(fakeEmployees[0]), 1000);
        assertEq(vestingContract.companyToken(), address(companyMockERC20));
        assertEq(vestingContract.startDate() > 0, true);
        assertEq(vestingContract.daysSincelastUnlock(), 0);
    }

    function testAccessControl() public {
        address prankEmployer = 0x0e729b11661B3f1C1E829AAdF764D5C3295e1256;
        vm.prank(prankEmployer);
        vm.expectRevert("You are not an employer");
        vestingContract.addEmployee(fakeEmployees[5], 1000);

        vm.prank(prankEmployer);
        vm.expectRevert("You are not an employer");
        vestingContract.depositTokens(10000000);

        vm.prank(prankEmployer);
        vm.expectRevert("You are not an employer");
        vestingContract.updateDaysSinceLastUnlock();

        vm.prank(prankEmployer);
        vm.expectRevert("You are not an employer");
        vestingContract.unlockTokens();
    }

    function testEmployeeManagement() public {
        address fakeEmployee = 0x7000000000000000000000000000000000000007;
        uint256 originalLength = vestingContract.getNumberOfEmployees();

        vestingContract.addEmployee(fakeEmployee, 1000);

        assertEq(vestingContract.isEmployeeLogic(fakeEmployee), true);
        assertEq(vestingContract.getNumberOfEmployees() == originalLength + 1 , true);

        vm.expectRevert("Employee already exists");
        vestingContract.addEmployee(fakeEmployee, 1000);
    }

    function testVesting() public {
        for (uint i = 0; i < 30; i++) {
            vestingContract.updateDaysSinceLastUnlock();
        }
        console.log("Days since last unlock:", vestingContract.daysSincelastUnlock());
        assertEq(vestingContract.daysSincelastUnlock(), 30);
        uint pre = IERC20(companyMockERC20).balanceOf(address(fakeEmployees[0]));
        vestingContract.unlockTokens();
        uint post = IERC20(companyMockERC20).balanceOf(address(fakeEmployees[0]));
        assertEq(post, 83);
    }

}