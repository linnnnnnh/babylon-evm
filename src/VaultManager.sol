// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./BabylonStrategyVault.sol";
import "./ByzBTC.sol";
import "./mocks/SymbioticVaultMock.sol";

contract VaultManager {
    /// @notice Address of the owner
    address public owner;
    /// @notice Address of the ByzBTC token
    ByzBTC public byzBTC;
    /// @notice Address of the Symbiotic Vault
    SymbioticVaultMock public symbioticVault;

    constructor(address initialOwner, address _byzBTC, address _symbioticVault) {
        owner = initialOwner;
        byzBTC = ByzBTC(_byzBTC);
        symbioticVault = SymbioticVaultMock(_symbioticVault);
    }

    /**
     * @notice Create a Babylon Strategy Vault and restake the ByzBTC tokens representing the staked BTC
     * @param _staker address of the staker
     * @param _satoshiAmount amount of the BTC to restake in satoshis
     * @param _depositTimestamp timestamp of the deposit
     * @param _duration duration of the BTC staking
     * @param _avs addresses of the AVS that the staker has delegated to
     * @param _allocations allocations in percentrage of the ByzBTC tokens to the AVS, scaled by 1e4
     */
    function createBabylonStratVaultAndRestake(address _babylonVault, bytes memory _btcPubKey, address _staker, uint256 _satoshiAmount, uint256 _depositTimestamp, uint256 _duration, address[] memory _avs, uint256[] memory _allocations) public {
        if (_babylonVault == address(0)) {
            // Create the strategy vault
            BabylonStrategyVault vault = new BabylonStrategyVault(address(byzBTC));

            // Mint the ByzBTC tokens to the vault which is the owner of the ByzBTC tokens 
            byzBTC.mint(address(vault), _satoshiAmount);

            // Register the staking details in the vault
            BabylonStrategyVault(vault).registerStaking(_staker, _satoshiAmount, _depositTimestamp, _duration, _btcPubKey);

            for (uint256 i = 0; i < _avs.length; i++) {
                for (uint256 j = 0; j < _allocations.length; j++) {
                    // Calculate the amount of ByzBTC to deposit to the AV
                    uint256 amount = _satoshiAmount * _allocations[j] / 1e4;

                    // Deposit the tokens to the vault
                    BabylonStrategyVault(vault).deposit(amount, _staker, _avs[j]);
                }
            }
        } else {
            // Mint the ByzBTC tokens to the vault which is the owner of the ByzBTC tokens 
            byzBTC.mint(address(_babylonVault), _satoshiAmount);

            // Register the staking details in the vault
            BabylonStrategyVault(_babylonVault).registerStaking(_staker, _satoshiAmount, _depositTimestamp, _duration, _btcPubKey);

            for (uint256 i = 0; i < _avs.length; i++) {
                for (uint256 j = 0; j < _allocations.length; j++) {
                    // Calculate the amount of ByzBTC to deposit to the AV
                    uint256 amount = _satoshiAmount * _allocations[j] / 1e4;

                    // Deposit the tokens to the vault
                    BabylonStrategyVault(_babylonVault).deposit(amount, _staker, _avs[j]);
                }
            }
        }
    }
}