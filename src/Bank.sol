// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/* 
 * @title Decentralised Banking system
 * @author Owusu Nelson Osei Tutu 
 * @notice A decentralised banking system that includes creating accounts, depositing funds ,transfering funds
 * savings and loans and insurance
*/

import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";

contract DecentralisedBank is AutomationCompatibleInterface{
    /* state variables */
    //owner of bank
    address public owner;
    //total funds in bank in case of emergency 
    //also part of savings account
    uint256 private total_value;

    //minimum amount to deposit in creating account
    uint256 public constant MINIMUM_AMOUNT = 0.01 ether;

    //array of all accounts created
    address [] public accountsCreated;
    address [] public savingsCreated;

    //track user accounts
    mapping (address => Account) public accounts;
    //track savings account
    mapping (address => SavingsAccount) public savings;

    //account format
    struct Account{
        string name;
        string email;
        uint256 balance;
        bool accountExist;
    }
    bool internal locked;
    
    //savings account format
    struct SavingsAccount{
        uint256 balance;
        bool accountExist;
    }

    /* Modifiers */

     /**
     * @notice This modifier ensures that only the address defined as the owner can call certain methods

     */
    modifier onlyBankOwner(){
        require(msg.sender == owner,"Only Bank owner can perform this functions");
        _;
    }
    /**
     * @notice This modifier prevents the account from being vunerable to reentrancy attacks

     */
    modifier noRentrancy() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    /**
    * @notice This modifier ensure only account owners can perform specific functions
    */
    modifier onlyAccountOwner(){
        require(accounts[msg.sender].accountExist,"only account owners can perform this function");
        _;
    }

    /*
    * @notice This modifier ensures that user has sufficient funds to perform certain functions
    */
    modifier hasSufficientFunds(address payable user,uint256 amount){
        require(accounts[user].balance > amount,"Insufficient funds");
        _;
    }

    /* Functions */

    constructor() payable {
        owner = msg.sender;
        total_value = msg.value;
    }

    /*
     * @notice This functions stores the initial amount the bank was started with
    */
     
     function storeEther() payable public onlyBankOwner{
        total_value += msg.value;
     }

    /*
      @notice this function is for creating user accounts
    */

    function createAccount(string memory _name,string memory _email) public payable {
        require(accounts[msg.sender].accountExist == false,"user must not already exist");
        require(msg.value >= MINIMUM_AMOUNT,"Insufficient deposit");

        accounts[msg.sender] = Account({
            name : _name,
            email : _email,
            accountExist : true,
            balance : msg.value
        });
        accountsCreated.push(msg.sender);
    }

    /*
     * @notice This function allows users to deposit amounts called only within the contract
    */
    function depositAccount(address _userAddress) internal{
        accounts[_userAddress].balance += msg.value;
    }

    function depositSaving(address _userAddress) internal{
        savings[_userAddress].balance += msg.value;
    }

    /*
    * @notice This function allows users to deposit money into their own accounts

    */

    function depositIntoMyAccount() public payable onlyAccountOwner{
        depositAccount(msg.sender);
    }

    /*
    * @notice This function allows users to deposit into others account if they have sufficient funds
    */

    function depositIntoOtherAccount(address _userAddress) 
    hasSufficientFunds(payable (msg.sender),msg.value)
     onlyAccountOwner public payable {
        require(_userAddress != msg.sender);
        depositAccount(_userAddress);
        accounts[msg.sender].balance -= msg.value;
    }

    /*
    * @notice This function allows users to withdraw money from thier bank account
    */

    function withdraw(address payable _to,uint256 amount) onlyAccountOwner hasSufficientFunds(_to,amount) noRentrancy public {
      accounts[_to].balance -= amount;

      (bool sent,)  = _to.call{value : amount}("");
      require(sent,"Transaction failed");
    }

    // The functions below are called when ether is sent to the contract in this case the bank contract
    receive() external payable {}

    fallback() external payable {}

    

    /*
    * @notice This function calculates interest on savings
    */

    mapping(address => uint256) public lastInterestUpdate;

/*
    function addInterestToAllSavingsAutomatically() public onlyBankOwner {
        // Check if a day has passed since the last interest update
       //require(block.timestamp - lastInterestUpdate[address(0)] >= 1 seconds, "Cannot add interest more than once a day");

        for (uint256 i = 0; i < savingsCreated.length; i++) {
            address savingsAccount = savingsCreated[i];
            require(savings[savingsAccount].accountExist == true, "Invalid savings account");

            // Calculate interest (10% of current savings balance)
            uint256 interest = (savings[savingsAccount].balance * 10) / 100;

            // Add interest to savings balance
            savings[savingsAccount].balance += interest;
        }

        // Update the last interest update timestamp for all savings accounts
       lastInterestUpdate[address(0)] = block.timestamp;
    }*/

    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
       upkeepNeeded = block.timestamp - lastInterestUpdate[address(0)] >= 1 days;
       return (upkeepNeeded,'0x0');
    }

    function performUpkeep(bytes calldata /* performData */) external override {
       (bool upkeepNeeded,) = checkUpkeep("");
       if(!upkeepNeeded){
        revert();
       }
       for (uint256 i = 0; i < savingsCreated.length; i++) {
            address savingsAccount = savingsCreated[i];
            require(savings[savingsAccount].accountExist == true, "Invalid savings account");

            // Calculate interest (10% of current savings balance)
            uint256 interest = (savings[savingsAccount].balance * 10) / 100;

            // Add interest to savings balance
            savings[savingsAccount].balance += interest;
            total_value -= interest;
        }

        // Update the last interest update timestamp for all savings accounts
       lastInterestUpdate[address(0)] = block.timestamp;
    }


    /*
    * @notice This function is for creating a savings account
    */

    function createSavingsAccount() public onlyAccountOwner{
       require(savings[msg.sender].accountExist == false,"user must not already have a savings account"); 
       savings[msg.sender] = SavingsAccount({
        balance : 0,
        accountExist : true
       });
       savingsCreated.push(msg.sender);
    }

    /*
    * @notice This function is for depositing into savings account
    */

    function depositIntoSavingsAccount() payable public {
        require(msg.value > 0,"value must not be zero");
        depositSaving(msg.sender);
    }

    /*
    * @notice This function is for withdrawing from savings account
    */

    function withdrawSavings(address payable _to,uint256 amount) noRentrancy public{
        require(savings[_to].accountExist == true,"user must have a savings account");
        require(savings[_to].balance > 0,"cannot withdraw zero value");

        savings[_to].balance -= amount;

       (bool sent,)  = _to.call{value : amount}("");
       require(sent,"Transaction failed");
    }


    /* Getter functions */

    /*
    * @notice this functions gets the balance in the bank
    */

    function getBankBalance() onlyBankOwner public view returns (uint256){
       return address(this).balance;
    }

    /*
    * @notice this function gets the balance of an account called by only the account owner
    */

    function getAccountBalance() onlyAccountOwner public view returns (uint256){
        return accounts[msg.sender].balance;
    }

    /*
    * @notice this function gets the number of accounts created
    */

    function getAllAcccountsNumber() public view returns (uint256){
       return accountsCreated.length;
    }


}