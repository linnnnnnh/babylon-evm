// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./ByzBTC.sol";
import "./mocks/SymbioticVaultMock.sol";
import {VaultManager} from "./VaultManager.sol";

contract BabylonStrategyVault {
    /// @notice Address of the ByzBTC token
    ByzBTC public byzBTC;

    /// @notice Address of the Symbiotic Vault
    SymbioticVaultMock public symbioticVault;

    /// @notice Address of the Vault Manager
    address public vaultManager;

    /// @notice Total amount of ByzBTC tokens staked in this vault
    uint256 public totalStaked;

    /// @notice Details of the staking
    struct StakingDetail {
        bytes btcPubKey;
        uint256 satoshiAmount;
        uint256 depositTimestamp;
        uint256 duration;
        uint256 exitTimestamp;
    }
    /// @notice Mapping to track the staking details of each staker ETH address
    mapping(address => StakingDetail) public stakingDetails;

    constructor(address _byzBTC, address _vaultManager, address[] memory _avs) {
        byzBTC = ByzBTC(_byzBTC);
        vaultManager = _vaultManager;
        symbioticVault = new SymbioticVaultMock(_byzBTC, _avs);
    }

    /**
     * @notice Deposit the ByzBTC tokens to the Symbiotic Vault
     * @param _amount amount of the ByzBTC to deposit
     * @param _staker address of the staker
     */
    function deposit(uint256 _amount, address _staker) public onlyVaultManager{
        // Ensure the BabylonStrategyVault has approved the SymbioticVAultMock contract to spend tokens
        IERC20(byzBTC).approve(address(symbioticVault), _amount);

        // Deposit the ByzBTC tokens to the Symbiotic Vault by calling the deposit function of the SymbioticVaultMock contract
        symbioticVault.deposit(_staker, _amount);

        // Update the total staked amount of BabylonStrategyVault
        totalStaked += _amount;
    }

    /**
     * @notice Withdraw the ByzBTC tokens from the Symbiotic Vault
     * @param _amount amount of the ByzBTC to withdraw
     * @param _staker address of the staker
     */
    function withdraw(uint256 _amount, address _staker) public onlyVaultManager {
        totalStaked -= _amount;
        // ... implement withdrawal logic ...
    }

    /**
     * @notice Get the total staked amount in the Babylon Strategy Vault
     * @return totalStaked amount of the ByzBTC tokens staked
     */
    function getTotalStaked() public view returns (uint256) {
        return totalStaked;
    }

    modifier onlyVaultManager() {
        if (msg.sender != vaultManager) revert OnlyVaultManager();
        _;
    }

    /// @notice Error if not called by the Vault Manager
    error OnlyVaultManager();
}
