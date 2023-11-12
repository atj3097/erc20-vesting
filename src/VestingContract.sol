// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract VestingContract {

    address public company;
    address public companyToken;
    address[] public employees;
    mapping (address => uint256) public employeeVestingAmounts;
    uint256 public totalVestingMonths;

    uint256 public startDate;
    uint256 public daysSincelastUnlock;



    constructor(address _companyToken,
        uint256 _totalVestingMonths,
        address _company) {
        companyToken = _companyToken;
        startDate = block.timestamp;
        daysSincelastUnlock = 0;
        totalVestingMonths = _totalVestingMonths;
        company = _company;
    }

    modifier isEmployee() {
        require(isEmployeeLogic(msg.sender), "You are not an employee");
        _;
    }

    function isEmployeeLogic(address _address) public view returns (bool) {
        for (uint i = 0; i < employees.length; i++) {
            if (employees[i] == _address) {
                return true;
            }
        }
        return false;
    }

    modifier isEmployer() {
        require(msg.sender == company, "You are not an employer");
        _;
    }

    function addEmployee(address newEmployee, uint256 vestingAmount) public isEmployer {
        require(!isEmployeeLogic(newEmployee), "Employee already exists");
        employees.push(newEmployee);
        employeeVestingAmounts[newEmployee] = vestingAmount;
    }

    function depositTokens(uint256 depositAmount) public isEmployer {
        IERC20(companyToken).transferFrom(msg.sender, address(this), depositAmount);
    }

    function updateDaysSinceLastUnlock() public isEmployer returns (uint256){
        //called by an external timer that triggers this function every 24 hours offchain
        daysSincelastUnlock += 1;
        return daysSincelastUnlock;
    }

    function unlockTokens() public isEmployer {
        require(daysSincelastUnlock >= 30);

        for(uint i = 0; i < employees.length; i++) {
            address currentEmployee = employees[i];

            uint256 monthlyVestingAmount = employeeVestingAmounts[currentEmployee] / totalVestingMonths;

            uint256 alreadyTransferred = IERC20(companyToken).balanceOf(currentEmployee);
            uint256 amountToTransfer = monthlyVestingAmount - alreadyTransferred;
            require(amountToTransfer > 0);
            IERC20(companyToken).transfer(currentEmployee, amountToTransfer);
            }
        daysSincelastUnlock = 0;
    }

    function getNumberOfEmployees() public view returns (uint) {
        return employees.length;
    }


}