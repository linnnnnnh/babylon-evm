// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {BabylonStrategyVault} from "../src/BabylonStrategyVault.sol";
import {SymbioticVaultMock} from "../src/mocks/SymbioticVaultMock.sol";

// forge script script/FetchSymbAddr.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY -vvv
contract FetchSymbAddr is Script {
    BabylonStrategyVault public vault;
    address constant VAULT_ADDRESS_1_AVS = 0x2b46c662f400549444296CF1DB1dD1fEBc21F552;
    address constant VAULT_ADDRESS_2_AVS = 0xEaFEbCAd5Ad24C670e565A68c6b042Fe21fAe837;
    address constant VAULT_ADDRESS_3_AVS = 0x32B92785200655bFd6818D57E3147f649285AA6e;

    function setUp() public {
        // Initialise le contrat avec l'adresse existante
        vault = BabylonStrategyVault(VAULT_ADDRESS_1_AVS);
    }

    function run() public {
        
        vm.startBroadcast();
        SymbioticVaultMock symbVault = vault.symbioticVault();
        console.log("Symbiotic Vault Address", address(symbVault));
        uint256 activeStake = symbVault.activeStake();
        console.log("Active Stake of Vault in Symbiotic", activeStake);
        vm.stopBroadcast();
    }
}
