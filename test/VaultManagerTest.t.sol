// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {VaultManager} from "../src/VaultManager.sol";
import {ByzBTC} from "../src/ByzBTC.sol";
import {SymbioticVaultMock} from "../src/mocks/SymbioticVaultMock.sol";
import {BabylonStrategyVault} from "../src/BabylonStrategyVault.sol";
import {DeployByzBTC} from "../script/DeployByzBTC.s.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC4626Math} from "../src/libraries/ERC4626Math.sol";


contract VaultManagerTest is Test {
    VaultManager vaultManager;
    ByzBTC byzBTC;

    /// @notice Owner of the vault manager which is the Byzantine Relayer
    address constant BYZANTINE_RELAYER_ADDRESS = 0x39ace511812E43dd318C81552Caf3C8EA4b178F2;

    /// @notice Symb strat 1
    address[] strat1 = [makeAddr("AVS1"), makeAddr("AVS2")];
    /// @notice Symb strat 2
    address[] strat2 = [makeAddr("AVS3"), makeAddr("AVS4")];

    /// @notice Symbiotic vaults
    SymbioticVaultMock symbioticVaultX;
    SymbioticVaultMock symbioticVaultY;

    // Stakers
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    /// @notice Initial balance of all the node operators
    uint256 internal constant STARTING_BALANCE = 500 ether;

    /// @notice Simulate a BTC staking dataset fetch from the replayer
    struct BtcStakingDataset {
        address babylonVault;
        bytes btcPubKey;
        address staker;
        uint256 satoshiAmount;
        uint256 depositTimestamp;
        uint256 duration;
        address[] avs;
        uint256[] allocations;
    }
    BtcStakingDataset[] btcStakingDataset;
    
    function setUp() external {
        // deploy the ByzBTC token
        DeployByzBTC deployByzBTC = new DeployByzBTC();
        byzBTC = deployByzBTC.run();

        // deploy the vault manager
        vaultManager = new VaultManager(BYZANTINE_RELAYER_ADDRESS, address(byzBTC));

        // fund the stakers
        vm.deal(alice, STARTING_BALANCE);
        vm.deal(bob, STARTING_BALANCE);
    }

    function test_createBabylonStratVault() external {
        vm.prank(BYZANTINE_RELAYER_ADDRESS);
        address babylonVault = vaultManager.createBabylonStratVault(strat1);
        assertEq(address(BabylonStrategyVault(babylonVault).byzBTC()), address(byzBTC));
    }

    // function test_restakeInBabylonVault() external {
    //     // Create the Babylon strategy vault
    //     vm.prank(BYZANTINE_RELAYER_ADDRESS);
    //     address babylonVault = vaultManager.createBabylonStratVault(strat2);

    //     uint256[] memory _allocations = new uint256[](2);
    //     _allocations[0] = 5000;
    //     _allocations[1] = 5000;

    //     btcStakingDataset.push(BtcStakingDataset({
    //         babylonVault: babylonVault,
    //         btcPubKey: hex"0339a36013301597daef46fbe57747e4d759d4508bc8dfe4d49165fbe43b6065c4",
    //         staker: alice,
    //         satoshiAmount: 100000000,
    //         depositTimestamp: 1725705600,
    //         duration: 31536000,
    //         avs: strat2,
    //         allocations: _allocations
    //     }));

    //     BtcStakingDataset memory dataset = btcStakingDataset[0];

    //     // Restake in the Babylon strategy vault
    //     vm.prank(BYZANTINE_RELAYER_ADDRESS);
    //     vaultManager.restakeInBabylonVault(
    //         dataset.btcPubKey,
    //         dataset.staker,
    //         dataset.satoshiAmount,
    //         dataset.depositTimestamp,
    //         dataset.duration,
    //         dataset.avs
    //     );

    //     // Check the total staked amount in the Babylon strategy vault
    //     uint256 totalStaked = BabylonStrategyVault(babylonVault).getTotalStaked();
    //     assertEq(totalStaked, dataset.satoshiAmount);

    //     // Check if the struct StakingDetail is set
    //     (
    //         bytes memory btcPubKey,
    //         uint256 satoshiAmount,
    //         uint256 depositTimestamp,
    //         uint256 duration,
    //         uint256 exitTimestamp
    //     ) = BabylonStrategyVault(babylonVault).stakingDetails(dataset.staker);
        
    //     assertEq(btcPubKey, dataset.btcPubKey);
    //     assertEq(satoshiAmount, dataset.satoshiAmount);
    //     assertEq(depositTimestamp, dataset.depositTimestamp);
    //     assertEq(duration, dataset.duration);
    //     assertEq(exitTimestamp, dataset.depositTimestamp + dataset.duration);

    //     // Check activeStake in the Symbiotic vaults
    //     uint256 amountInVaultX = (_allocations[0] * dataset.satoshiAmount) / 1e4; 
    //     uint256 amountInVaultY = (_allocations[1] * dataset.satoshiAmount) / 1e4;
    //     assertEq(symbioticVaultX.activeStake(), amountInVaultX);
    //     assertEq(symbioticVaultY.activeStake(), amountInVaultY);

    //     // Check activeSharesOf in the Symbiotic vaults
    //     uint256 mintedSharesInX = ERC4626Math.previewDeposit(amountInVaultX, symbioticVaultX.activeShares(), symbioticVaultX.activeStake());
    //     uint256 mintedSharesInY = ERC4626Math.previewDeposit(amountInVaultY, symbioticVaultY.activeShares(), symbioticVaultY.activeStake());
    //     console.log("mintedSharesInX", mintedSharesInX);
    //     console.log("mintedSharesInY", mintedSharesInY);

    //     assertEq(symbioticVaultX.activeSharesOf(dataset.staker), mintedSharesInX);
    //     assertEq(symbioticVaultY.activeSharesOf(dataset.staker), mintedSharesInY);
    // }

    /* ===================== MODIFIERS ===================== */

    modifier startAtPresentDay() {
        vm.warp(1730995913);
        _;
    }
 }