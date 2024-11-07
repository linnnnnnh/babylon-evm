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

    /// @notice Mapping to track a strategy and its vault address
    mapping(bytes32 => address) public idToStratVault;

    constructor(address _byzantineRelayerAddress, address _byzBTC) {
        byzantineRelayerAddress = _byzantineRelayerAddress;
        byzBTC = ByzBTC(_byzBTC);
    }

    /**
     * @notice Create a Babylon Strategy Vault
     */
    function createBabylonStratVault(
        address[] memory _avs
    ) public onlyByzantineRelayer returns (address) {
        bytes32 avsHash = keccak256(abi.encodePacked(_avs));
        if (idToStratVault[avsHash] == address(0)) {
            idToStratVault[avsHash] = address(new BabylonStrategyVault(address(byzBTC), address(this), _avs));
        }
        return idToStratVault[avsHash];
    }

    /**
     * @notice Restake the ByzBTC tokens representing the staked BTC
     * @param _staker address of the staker
     * @param _satoshiAmount amount of the BTC to restake in satoshis
     * @param _depositTimestamp timestamp of the deposit
     * @param _duration duration of the BTC staking
     * @param _avs addresses of the AVS that the staker has delegated to
     */
    function restakeInBabylonVault(
        bytes memory _btcPubKey,
        address _staker,
        uint256 _satoshiAmount,
        uint256 _depositTimestamp,
        uint256 _duration,
        address[] memory _avs
    ) public onlyByzantineRelayer returns (address) {

        // Verify if the vault exists for such an AVS strategy
        bytes32 avsHash = keccak256(abi.encodePacked(_avs));
        address _babylonVault = idToStratVault[avsHash];
        require(_babylonVault != address(0), "BabylonVaultDoesNotExist");
        
        // Mint the ByzBTC tokens to the strategy Babylon vault
        byzBTC.mint(_babylonVault, _satoshiAmount);
        
        // Register staking details
        BabylonStrategyVault(_babylonVault).registerStaking(
            _staker,
            _satoshiAmount,
            _depositTimestamp,
            _duration,
            _btcPubKey
        );

        BabylonStrategyVault(_babylonVault).deposit(_satoshiAmount, _staker);

        return _babylonVault;
    }


    modifier onlyByzantineRelayer() {
        if (msg.sender != byzantineRelayerAddress) revert OnlyByzantineRelayer();
        _;
    }

    /// @notice Error for mismatching lengths of arrays
    error LengthMismatch();

    /// @notice Error for only the Byzantine Relayer
    error OnlyByzantineRelayer();
}
