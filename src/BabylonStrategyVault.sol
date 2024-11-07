// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./ByzBTC.sol";
import "./mocks/SymbioticVaultMock.sol";

contract BabylonStrategyVault {
    /// @notice Address of the ByzBTC token
    ByzBTC public byzBTC;

    /// @notice Details of the staking
    struct StakingDetail {
        bytes btcPubKey;
        uint256 satoshiAmount;
        uint256 depositTimestamp;
        uint256 duration;
        uint256 exitTimestamp;
    }
    mapping(address => StakingDetail) public stakingDetails;

    constructor(address _byzBTC) {
        byzBTC = ByzBTC(_byzBTC);
    }

    /**
     * @notice Mint the ByzBTC tokens to the vault
     * @param to address of the recipient
     * @param amount amount of the ByzBTC to mint which is 1:1 to the amount of BTC staked
     */
    function mintByzBTC(address to, uint256 amount) public {
        byzBTC.mint(to, amount);
    }

    /**
     * @notice Register the staking details
     * @param _staker address of the staker
     * @param _satoshiAmount amount of the BTC to stake in satoshis
     * @param _depositTimestamp timestamp of the deposit
     * @param _duration duration of the BTC staking
     */
    function registerStaking(address _staker, uint256 _satoshiAmount, uint256 _depositTimestamp, uint256 _duration, bytes memory _btcPubKey) public {
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
    function deposit(uint256 _amount, address _staker, address _avs) public {
        SymbioticVaultMock(_avs).deposit(_staker, _amount);
    }

    function withdraw(uint256 _amount, address _staker) public {}

}