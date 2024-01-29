//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Script} from 'forge-std/Script.sol';
import {DecentralisedBank} from '../src/Bank.sol';

contract DeployBank is Script{
    function run() external returns (DecentralisedBank){
       vm.startBroadcast();
       DecentralisedBank decBank = new DecentralisedBank();
       vm.stopBroadcast();
       return decBank;
    }
}