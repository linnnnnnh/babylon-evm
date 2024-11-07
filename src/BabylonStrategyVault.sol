// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./ByzBTC.sol";
import "./mocks/SymbioticVaultMock.sol";
import {VaultManager} from "./VaultManager.sol";

contract BabylonStrategyVault {
    /// @notice Address of the ByzBTC token
    ByzBTC public byzBTC;

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

    constructor(address _byzBTC, address _vaultManager) {
        byzBTC = ByzBTC(_byzBTC);
        vaultManager = _vaultManager;
    }

    /**
     * @notice Mint the ByzBTC tokens to the vault
     * @param to address of the recipient
     * @param amount amount of the ByzBTC to mint which is 1:1 to the amount of BTC staked
     */
    function mintByzBTC(address to, uint256 amount) public onlyVaultManager {
        byzBTC.mint(to, amount);
    }

    /**
     * @notice Register the staking details
     * @param _staker address of the staker
     * @param _satoshiAmount amount of the BTC to stake in satoshis
     * @param _depositTimestamp timestamp of the deposit
     * @param _duration duration of the BTC staking
     */
    function registerStaking(address _staker, uint256 _satoshiAmount, uint256 _depositTimestamp, uint256 _duration, bytes memory _btcPubKey) public onlyVaultManager {
        // Calculate the timestamp corresponding to timelock
        uint256 exitTimestamp = _depositTimestamp + _duration;

        // Update the staking details 
        stakingDetails[_staker] = StakingDetail(_btcPubKey, _satoshiAmount, _depositTimestamp, _duration, exitTimestamp);
    }

    /**
     * @notice Deposit the ByzBTC tokens to the Symbiotic Vault
     * @param _amount amount of the ByzBTC to deposit
     * @param _staker address of the staker
     */
    function deposit(uint256 _amount, address _staker, address _avs) public onlyVaultManager{
        // Ensure the BabylonStrategyVault has approved the SymbioticVAultMock contract to spend tokens
        IERC20(byzBTC).approve(_avs, _amount);

        // Deposit the ByzBTC tokens to the Symbiotic Vault by calling the deposit function of the SymbioticVaultMock contract
        SymbioticVaultMock(_avs).deposit(_staker, _amount);

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
