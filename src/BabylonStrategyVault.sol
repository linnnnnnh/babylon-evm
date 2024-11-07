// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ByzBTC.sol";

contract BabylonStrategyVault is ERC20 {
    ByzBTC public byzBTC;

    uint256 private satoshiBalance;

    struct StakingDetail {
        uint256 satoshiAmount;
        uint256 depositTimestamp;
        uint256 duration;
        SpendingPath spendingPath;
    }
    mapping(address => StakingDetail) public stakingDetails;

    enum SpendingPath {
        Timelock,
        Unbonding
    }

    constructor(address _byzBTC)
        ERC20("ByzBTC", "BBTC")
    {
        byzBTC = ByzBTC(_byzBTC);
    }

    function registerStaking(address staker, uint256 satoshiAmount, uint256 depositTimestamp, uint256 duration, SpendingPath spendingPath) public {
        // Mint the ByzBTC tokens
        _mintByzBTC(address(this), satoshiAmount);

        // Update the staking details 
        stakingDetails[staker] = StakingDetail(satoshiAmount, depositTimestamp, duration, spendingPath);
    }

    function deposit(uint256 _amount, address _staker) public {
        satoshiBalance += _amount;
    }

    function withdraw(uint256 _amount, address _staker) public {}


    function _mintByzBTC(address to, uint256 amount) internal {
        byzBTC.mint(to, amount);
    }
}