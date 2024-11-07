// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {VaultManager} from "../src/VaultManager.sol";
import {ByzBTC} from "../src/ByzBTC.sol";
import {SymbioticVaultMock} from "../src/mocks/SymbioticVaultMock.sol";
import {DeployByzBabylon} from "../script/DeployByzBabylon.s.sol";
import {DeployByzBTC} from "../script/DeployByzBTC.s.sol";
import {DeploySymbiotic} from "../script/DeploySymbiotic.s.sol";

contract VaultManagerTest is Test {
    VaultManager vaultManager;
    ByzBTC byzBTC;
    SymbioticVaultMock symbioticVaultX;
    SymbioticVaultMock symbioticVaultY;

    function setUp() external {
        DeployByzBTC deployByzBTC = new DeployByzBTC();
        byzBTC = deployByzBTC.run();

        DeploySymbiotic deploySymbiotic = new DeploySymbiotic();
        symbioticVaultX = deploySymbiotic.run();
        symbioticVaultY = deploySymbiotic.run();

        DeployByzBabylon deployByzBabylon = new DeployByzBabylon();
        vaultManager = deployByzBabylon.run();
    }
 }