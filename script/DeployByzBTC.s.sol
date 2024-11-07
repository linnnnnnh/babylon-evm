// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {ByzBTC} from "../src/ByzBTC.sol";

contract DeployByzBTC is Script {

    function run() public returns (ByzBTC) {
        vm.startBroadcast();
        ByzBTC byzBTC = new ByzBTC();
        vm.stopBroadcast();

        return byzBTC;
    }
}
