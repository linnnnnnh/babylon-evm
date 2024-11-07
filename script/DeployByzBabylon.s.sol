// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {VaultManager} from "../src/VaultManager.sol";
import {BabylonStrategyVault} from "../src/BabylonStrategyVault.sol";
import {ByzBTC} from "../src/ByzBTC.sol";
import {SymbioticVaultMock} from "../src/mocks/SymbioticVaultMock.sol";

contract DeployByzBabylon is Script {
    SymbioticVaultMock symbioticVault;
    ByzBTC byzBTC;

    function run() public returns (VaultManager) {
        vm.startBroadcast();
        VaultManager vaultManager = new VaultManager(msg.sender, address(byzBTC), address(symbioticVault));
        vm.stopBroadcast();

        return vaultManager;
    }


}
