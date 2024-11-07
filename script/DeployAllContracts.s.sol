// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {ByzBTC} from "../src/ByzBTC.sol";
import {SymbioticVaultMock} from "../src/mocks/SymbioticVaultMock.sol";
import {VaultManager} from "../src/VaultManager.sol";

contract DeployAllContracts is Script {
    address constant BYZANTINE_RELAYER_ADDRESS = 0x39ace511812E43dd318C81552Caf3C8EA4b178F2;

    function run() public returns (ByzBTC, SymbioticVaultMock, SymbioticVaultMock, SymbioticVaultMock, SymbioticVaultMock, VaultManager) {
        vm.startBroadcast();
        ByzBTC byzBTC = new ByzBTC();
        SymbioticVaultMock symbioticVaultW = new SymbioticVaultMock(address(byzBTC));
        SymbioticVaultMock symbioticVaultX = new SymbioticVaultMock(address(byzBTC));
        SymbioticVaultMock symbioticVaultY = new SymbioticVaultMock(address(byzBTC));
        SymbioticVaultMock symbioticVaultZ = new SymbioticVaultMock(address(byzBTC));
        VaultManager vaultManager = new VaultManager(BYZANTINE_RELAYER_ADDRESS, address(byzBTC));
        vm.stopBroadcast();

        return (byzBTC, symbioticVaultW, symbioticVaultX, symbioticVaultY, symbioticVaultZ, vaultManager);
    }
}
