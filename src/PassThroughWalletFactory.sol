// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {LibClone} from "splits-utils/LibClone.sol";

import {PassThroughWalletImpl} from "src/PassThroughWalletImpl.sol";

/// @title Pass-Through Wallet Factory
/// @author 0xSplits
/// @notice Factory for creating pass-through wallets.
/// @dev This contract uses token = address(0) to refer to ETH.
contract PassThroughWalletFactory {
    /// -----------------------------------------------------------------------
    /// libraries
    /// -----------------------------------------------------------------------

    using LibClone for address;

    /// -----------------------------------------------------------------------
    /// events
    /// -----------------------------------------------------------------------

    event CreatePassThroughWallet(
        PassThroughWalletImpl indexed passThroughWallet, PassThroughWalletImpl.InitParams params
    );

    /// -----------------------------------------------------------------------
    /// storage - constants & immutables
    /// -----------------------------------------------------------------------

    PassThroughWalletImpl public immutable passThroughWalletImpl;

    /// -----------------------------------------------------------------------
    /// constructor
    /// -----------------------------------------------------------------------

    constructor() {
        passThroughWalletImpl = new PassThroughWalletImpl();
    }

    /// -----------------------------------------------------------------------
    /// functions - public & external
    /// -----------------------------------------------------------------------

    function createPassThroughWallet(PassThroughWalletImpl.InitParams calldata params_)
        external
        returns (PassThroughWalletImpl passThroughWallet)
    {
        passThroughWallet = PassThroughWalletImpl(payable(address(passThroughWalletImpl).clone()));
        passThroughWallet.initializer(params_);
        emit CreatePassThroughWallet({passThroughWallet: passThroughWallet, params: params_});
    }
}
