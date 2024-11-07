// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./BabylonStrategyVault.sol";
import "./ByzBTC.sol";
import "./mocks/SymbioticVaultMock.sol";

contract VaultManager {
    /// @notice Address of the Byzantine Relayer
    address public byzantineRelayerAddress;
    /// @notice Address of the ByzBTC token
    ByzBTC public byzBTC;

    constructor(address _byzantineRelayerAddress, address _byzBTC) {
        byzantineRelayerAddress = _byzantineRelayerAddress;
        byzBTC = ByzBTC(_byzBTC);
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
    function createBabylonStratVaultAndRestake(
        address _babylonVault,
        bytes memory _btcPubKey,
        address _staker,
        uint256 _satoshiAmount,
        uint256 _depositTimestamp,
        uint256 _duration,
        address[] memory _avs,
        uint256[] memory _allocations
    ) public returns (address) {
        // Ensure arrays have matching lengths
        if (_avs.length != _allocations.length) revert LengthMismatch();
        
        // Create new vault if not provided
        address babylonVaultAddress = _babylonVault == address(0) 
            ? address(new BabylonStrategyVault(address(byzBTC)))
            : _babylonVault;
        
        // Mint the ByzBTC tokens to the strategy Babylon vault
        byzBTC.mint(babylonVaultAddress, _satoshiAmount);
        
        // Register staking details
        BabylonStrategyVault(babylonVaultAddress).registerStaking(
            _staker,
            _satoshiAmount,
            _depositTimestamp,
            _duration,
            _btcPubKey
        );
        
        // Deposit the ByzBTC tokens to the Symbiotic vault
        for (uint256 i = 0; i < _avs.length; i++) {
            uint256 amount = (_satoshiAmount * _allocations[i]) / 1e4;
            BabylonStrategyVault(babylonVaultAddress).deposit(amount, _staker, _avs[i]);
        }

        return babylonVaultAddress;
    }

    error LengthMismatch();
}