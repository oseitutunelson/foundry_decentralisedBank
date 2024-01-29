//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {DeployBank} from '../script/deployBank.s.sol';
import {DecentralisedBank} from '../src/Bank.sol';
import {Test} from 'forge-std/Test.sol';

contract TestBank is Test{
    DecentralisedBank decBank;
    address USER = makeAddr('user');
    address USER2 = makeAddr('user2');

    function setUp() public{
        DeployBank deployBank = new DeployBank();
        decBank = deployBank.run();
        vm.deal(USER,10 ether);
    }

    function testMinimumEther() public view{
        assert(decBank.getMinimumEth() == 0.01 ether);
    }

    function testCreateAccount() public{
        vm.prank(USER);
        decBank.createAccount{value : 1 ether}('Edward','edward@gmail.com');
        assertEq(decBank.getAllAcccountsNumber(),1);
        vm.prank(USER);
        assertEq(decBank.getAccountBalance(),1 ether);
    }

    function testDepositIntoMyAccount() public{
        vm.prank(USER);
        decBank.createAccount{value : 1 ether}('Edward','edward@gmail.com');
        vm.prank(USER);
        decBank.depositIntoMyAccount{value : 2 ether}();
        vm.prank(USER);
        assertEq(decBank.getAccountBalance(),3 ether);
    }

    function testDepositIntoOtherAccount() public{
        uint256 amountDeposit = 1 ether;
        uint256 amountSend = 0.2 ether;
        vm.prank(USER);
        decBank.createAccount{value : amountDeposit}('Edward','edward@gmail.com');
        vm.prank(USER);
        bool success = decBank.depositIntoOtherAccount{value : amountSend}(USER2);
        assertEq(success,true);
    }

    function testWithdrawFromAccount() public{
        vm.prank(USER);
        decBank.createAccount{value : 2 ether}('Edward','edward@gmail.com');
        vm.prank(USER);
        decBank.withdraw(payable(USER),1 ether);
        vm.prank(USER);
        assertEq(decBank.getAccountBalance(), 1 ether);
    }

    function testCreateSavingsAccount() public{
        vm.prank(USER);
        decBank.createAccount{value : 1 ether}('Edward','edward@gmail.com');
        vm.prank(USER);
        decBank.createSavingsAccount();
        assertEq(decBank.getAllSavinsgAccounts(),1);
    }

    function testDepositIntoSavingsAccount() public{
        vm.prank(USER);
        decBank.createAccount{value : 1 ether}('Edward','edward@gmail.com');
        vm.prank(USER);
        decBank.createSavingsAccount();
        vm.prank(USER);
        decBank.depositIntoSavingsAccount{value : 3 ether}();
        vm.prank(USER);
        assertEq(decBank.getSavingsBalance(),3 ether);
    }
    
    function testWithdrawFromSavingsAccount() public{
        vm.prank(USER);
        decBank.createAccount{value : 1 ether}('Edward','edward@gmail.com');
        vm.prank(USER);
        decBank.createSavingsAccount();
        vm.prank(USER);
        decBank.depositIntoSavingsAccount{value : 3 ether}();
        vm.prank(USER);
        decBank.withdrawSavings(payable(USER),2 ether);
        vm.prank(USER);
        assertEq(decBank.getSavingsBalance(),1 ether);
    }
}