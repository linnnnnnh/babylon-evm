// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC4626Math} from "../libraries/ERC4626Math.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {console} from "forge-std/console.sol";

contract SymbioticVaultMock {
    using Math for uint256;

    /// @notice Address of the collateral token which is ByzBTC
    address public byzBTC;

    /// @notice Balance of the BTC staked in the vault
    uint256 public activeStake;

    /// @notice Total amount of shares in the vault
    uint256 public activeShares;

    /// @notice Amount of shares of a staker
    mapping(address => uint256) public activeSharesOf;

    // /// @notice Mapping to track the deposit timestamp of each staker
    // mapping(address => uint256) public depositTimestamps;

    constructor(address _byzBTC) {
        byzBTC = _byzBTC;
    }

    /**
     * @notice Deposit collateral into the vault.
     * @param staker address of the staker
     * @param amount amount of the collateral to deposit
     * @return depositedAmount amount of the collateral deposited
     * @return mintedShares amount of the active shares minted
     */
    function deposit(address staker, uint256 amount) external returns (uint256 depositedAmount, uint256 mintedShares) {
        if (staker == address(0)) revert InvalidStaker();

        uint256 balanceBefore = IERC20(byzBTC).balanceOf(address(this));

        // Transfer the ByzBTC tokens from the BabylonStrategyVault to the SymbioticVaultMock
        IERC20(byzBTC).transferFrom(msg.sender, address(this), amount);
        depositedAmount = IERC20(byzBTC).balanceOf(address(this)) - balanceBefore;

        if (depositedAmount == 0) revert InsufficientDeposit();

        mintedShares = ERC4626Math.previewDeposit(depositedAmount, activeShares, activeStake);

        activeShares += mintedShares;
        activeStake += depositedAmount;
        activeSharesOf[staker] += mintedShares;
        // depositTimestamps[staker] = block.timestamp;

        emit Deposit(staker, depositedAmount, mintedShares);
    }

    /**
     * @notice Withdraw collateral from the vault.
     * @param staker address of the staker
     * @return withdrawnAmount amount of the collateral withdrawn
     */
    function withdraw(address staker) external returns (uint256 withdrawnAmount) {
        uint256 stakerShares = activeSharesOf[staker];
        if (stakerShares == 0) {
            revert NoShares();
        }

        // uint256 depositTime = depositTimestamps[staker];
        // uint256 elapsedTime = block.timestamp - depositTime;
        // uint256 daysElapsed = elapsedTime / 1 days;

        withdrawnAmount = ERC4626Math.previewWithdraw(stakerShares, activeShares, activeStake);

        activeShares -= stakerShares;
        activeStake -= withdrawnAmount;
        activeSharesOf[staker] = 0;
        // depositTimestamps[staker] = 0;

        IERC20(byzBTC).transfer(staker, withdrawnAmount);

        emit Withdraw(staker, withdrawnAmount);
    }


    /**
     * @notice Emitted when a deposit is made.
     * @param staker address of the staker
     * @param amount amount of the collateral deposited
     * @param shares amount of the active shares minted
     */
    event Deposit(address indexed staker, uint256 amount, uint256 shares);

    /**
     * @notice Emitted when a withdrawal is made.
     * @param staker address of the staker
     * @param amount amount of the collateral withdrawn
     */
    event Withdraw(address indexed staker, uint256 amount);

    error InvalidStaker();  
    error InsufficientDeposit();
    error NoShares();
}
