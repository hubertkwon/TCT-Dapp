pragma solidity ^0.4.16;

interface token {
    function transfer(address receiver, uint256 amount) public;    
}

contract simpleCrowdFund{
    address public beneficiary;
    uint public fundingGoal;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool public fundingGoalReached = false;
    bool public crowdsaleClosed = false;

    event GoalReached(address beneficiaryAddress, uint amountRaisedValue);
    event FundTransfer(address backer, uint amout, bool isContribution);

    function simpleCrowdFund(
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint durationInMinutes,
        uint etherCostOfEachToken,
        address addressOfTokenUsedAsReward
    ) public {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = (now + durationInMinutes) * 1 minutes;
        price = etherCostOfEachToken * 1 ether;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    function () external payable{
        require(!crowdsaleClosed);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount/price);
        FundTransfer(msg.sender,amount,true);
    }

    modifier afterDeadline() { if(now >= deadline) _;}

    function checkGoalReached() external afterDeadline{
        if(amountRaised >= fundingGoal){
            fundingGoalReached = true;
            GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }

    function safeWithdrawal() external afterDeadline{
        if(!fundingGoalReached)

    }

}

