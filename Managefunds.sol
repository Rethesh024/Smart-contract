// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FundManager {
    
    address payable private owner; // the owner of the contract
    
    uint public withdrawalLimit; // the maximum amount that can be withdrawn at once
    
    mapping(address => bool) public whitelisted; // a whitelist of addresses that are allowed to withdraw funds
    
    uint public timeLockPeriod; // the period of time during which funds cannot be withdrawn
    
    bool public emergencyStop; // a flag that can be set by the owner to prevent all withdrawals in case of an emergency
    
    uint public withdrawalFee; // a fee that is charged on each withdrawal to cover the gas costs of executing the transaction
    
    uint public minBalance; // a minimum balance that must be maintained in the contract to cover any withdrawals
    
    uint public rewardPercentage; // a percentage of the funds deposited that is offered as a reward to users
    
    event Withdrawal(address indexed from, address indexed to, uint amount);
    event Deposit(address indexed from, uint amount);
    
    constructor(uint _withdrawalLimit, uint _timeLockPeriod, uint _withdrawalFee, uint _minBalance, uint _rewardPercentage) {
        owner = payable(msg.sender);
        withdrawalLimit = _withdrawalLimit;
        timeLockPeriod = _timeLockPeriod;
        withdrawalFee = _withdrawalFee;
        minBalance = _minBalance;
        rewardPercentage = _rewardPercentage;
    }
    
    function withdrawFunds(uint _amount) payable public {
    require(emergencyStop == false, "Withdrawals are currently disabled due to an emergency");
    require(whitelisted[msg.sender] == true, "Sender address is not whitelisted");
    require(block.timestamp >= timeLockPeriod, "Funds cannot be withdrawn during the time lock period");
    require(_amount <= withdrawalLimit, "Amount exceeds withdrawal limit");
    require(address(this).balance - _amount >= minBalance, "Insufficient funds to cover withdrawal");
    payable(msg.sender).transfer(_amount - withdrawalFee);
    emit Withdrawal(address(this), msg.sender, _amount);
}

    
    function setWithdrawalLimit(uint _newLimit) public {
        require(msg.sender == owner, "Only the owner can change the withdrawal limit");
        withdrawalLimit = _newLimit;
    }
    
    function setWhitelisted(address _address, bool _status) public {
        require(msg.sender == owner, "Only the owner can modify the whitelist");
        whitelisted[_address] = _status;
    }
    
    function setTimeLockPeriod(uint _newPeriod) public {
        require(msg.sender == owner, "Only the owner can change the time lock period");
        timeLockPeriod = _newPeriod;
    }
    
    function setEmergencyStop(bool _status) public {
        require(msg.sender == owner, "Only the owner can set the emergency stop flag");
        emergencyStop = _status;
    }
    
    function setWithdrawalFee(uint _newFee) public {
        require(msg.sender == owner, "Only the owner can change the withdrawal fee");
        withdrawalFee = _newFee;
    }
    
    function setMinBalance(uint _newBalance) public {
        require(msg.sender == owner, "Only the owner can change the minimum balance");
        minBalance = _newBalance;
    }
    
    function setRewardPercentage(uint _newPercentage) public {
        require(msg.sender == owner, "Only the owner can change the reward percentage");
        rewardPercentage = _newPercentage;
    }
    
    function depositFunds() public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        uint reward = msg.value * rewardPercentage / 100;
        payable(msg.sender).transfer(reward);
        emit Deposit(msg.sender, msg.value);
    }
function getContractBalance() public view returns (uint) {
    return address(this).balance;
}

function getRewardAmount(uint _amount) public view returns (uint) {
    return _amount * rewardPercentage / 100;
}

function getWithdrawalFee() public view returns (uint) {
    return withdrawalFee;
}
}
