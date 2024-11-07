// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./BabylonStrategyVault.sol";
import "./ByzBTC.sol";

contract VaultManager {
    address public owner;
    ByzBTC public byzBTC;

    constructor(address initialOwner, address _byzBTC) {
        owner = initialOwner;
        byzBTC = ByzBTC(_byzBTC);
    }

    function createBabylonStratVault(address _staker, uint256 _satoshiAmount, uint256 _duration, BabylonStrategyVault.SpendingPath _spendingPath) public {
        // Create the strategy vault
        BabylonStrategyVault vault = new BabylonStrategyVault(address(byzBTC));

        // Register the staking
        BabylonStrategyVault(vault).registerStaking(_staker, _satoshiAmount, block.timestamp, _duration, _spendingPath);

        // Deposit the tokens to the vault
        BabylonStrategyVault(vault).deposit(_satoshiAmount, _staker);
    }


}