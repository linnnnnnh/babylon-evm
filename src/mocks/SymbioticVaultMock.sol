// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC4626Math} from "../libraries/ERC4626Math.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract SymbioticVaultMock {
    using SafeERC20 for IERC20;
    using Math for uint256;

    /// @notice Address of the collateral token which is ByzBTC
    address public byzBTC;

    /// @notice Balance of the BTC staked in the vault
    uint256 public activeStake;

    /// @notice Total amount of shares in the vault
    uint256 public activeShares;

    /// @notice Amount of shares of a staker
    mapping(address => uint256) public activeSharesOf;

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
    function deposit(
        address staker,
        uint256 amount
    ) external returns (uint256 depositedAmount, uint256 mintedShares) {
        if (staker == address(0)) {
            revert InvalidStaker();
        }

        uint256 balanceBefore = IERC20(byzBTC).balanceOf(address(this));
        IERC20(byzBTC).safeTransferFrom(msg.sender, address(this), amount);
        depositedAmount = IERC20(byzBTC).balanceOf(address(this)) - balanceBefore;

        if (depositedAmount == 0) {
            revert InsufficientDeposit();
        }

        mintedShares = ERC4626Math.previewDeposit(depositedAmount, activeShares, activeStake);

        activeShares += mintedShares;
        activeStake += depositedAmount;
        activeSharesOf[staker] += mintedShares;

        emit Deposit(staker, depositedAmount, mintedShares);
    }

    /**
     * @notice Emitted when a deposit is made.
     * @param staker address of the staker
     * @param amount amount of the collateral deposited
     * @param shares amount of the active shares minted
     */
    event Deposit(address indexed staker, uint256 amount, uint256 shares);


    error InvalidStaker();  
    error InsufficientDeposit();
}
