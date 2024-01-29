# Decentralised Banking System

## Overview

This smart contract implements a decentralized banking system on the Ethereum blockchain. It allows users to create accounts, deposit and withdraw funds, create savings accounts, and automatically add interest to savings on a daily basis.Also borrow loans. The contract is written in Solidity and is intended for deployment on the Ethereum blockchain.It uses 
chainlink Automation to calculate the interest on daily basis.

## Features

- **Account Creation:** Users can create bank accounts by providing their name, email, and making an initial deposit.
- **Fund Operations:** Users can deposit and withdraw funds from their accounts, as well as transfer funds to other accounts.
- **Savings Accounts:** Users can create savings accounts, deposit into them, and withdraw from them.
- **Automatic Interest:** The contract automatically adds 10% interest to all savings accounts every day.
- **Owner Privileges:** Certain functions can only be executed by the contract owner, providing control over critical 
- **Loans:** Borrow loans and pay back
--operations.

# Usage

- Creating an Account:
        Call the createAccount function, providing a name, email, and the minimum required deposit.

- Deposit and Withdraw:
        Use depositIntoMyAccount to deposit funds into your account.
        Use withdraw to withdraw funds from your account.

- Savings Account:
        Create a savings account using createSavingsAccount.
        Deposit into the savings account using depositIntoSavingsAccount.
        Withdraw from the savings account using withdrawSavings.

- Automatic Interest:
        The contract owner can call addInterestToAllSavingsAutomatically to add 10% interest to all savings accounts automatically. This uses chainlink automation to achieve this

# Owner Functions

- Certain functions can only be executed by the contract owner:

    storeEther: Store additional funds in the bank.
    addInterestToAllSavingsAutomatically: Add 10% interest to all savings accounts automatically.
