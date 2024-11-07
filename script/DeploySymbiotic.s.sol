// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {SymbioticVaultMock} from "../src/mocks/SymbioticVaultMock.sol";
import {ByzBTC} from "../src/ByzBTC.sol";

contract DeploySymbiotic is Script {
    ByzBTC byzBTC;

    function run() public returns (SymbioticVaultMock) {
        vm.startBroadcast();

        SymbioticVaultMock symbioticVault = new SymbioticVaultMock(address(byzBTC));
        vm.stopBroadcast();

        return symbioticVault;
    }


}
