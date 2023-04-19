// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "splits-tests/base.t.sol";

import {
    Initialized_PausableImplBase,
    PausableImplHarness,
    Uninitialized_PausableImplBase
} from "splits-tests/PausableImpl/PausableImplStateTree.sol";
import {OwnableImplHarness} from "splits-tests/OwnableImpl/OwnableImplStateTree.sol";

import {PassThroughWalletFactory} from "../../src/PassThroughWalletFactory.sol";
import {PassThroughWalletImpl} from "../../src/PassThroughWalletImpl.sol";

// State tree
//  Uninitialized
//  Initialized
//   Paused
//   Unpaused

abstract contract Uninitialized_PassThroughWalletImplBase is Uninitialized_PausableImplBase {
    event SetPassThrough(address passThrough);
    event PassThrough(address[] tokens, uint256[] amounts);

    /// Uninitialized_OwnableImplBase storage
    /* OwnableImplHarness $ownable; */
    /* address $owner; */
    /* address $notOwner; */
    /* address $nextOwner; */

    /// Uninitialized_PausableImplBase storage
    /* PausableImplHarness $pausable; */
    /* bool $paused; */

    PassThroughWalletFactory $passThroughWalletFactory;
    PassThroughWalletImpl $passThroughWalletImpl;
    PassThroughWalletImpl $passThroughWallet;

    address $passThrough;
    address $nextPassThrough;
    address $notFactory;

    uint256 constant NUM_TOKENS = 2;
    address[] tokens;

    function setUp() public virtual override {
        BaseTest.setUp();

        $passThroughWalletFactory = new PassThroughWalletFactory();
        $passThroughWalletImpl = $passThroughWalletFactory.passThroughWalletImpl();

        // Uninitialized_OwnableImplBase - other setup
        $owner = users.alice;
        $nextOwner = users.bob;
        $notOwner = users.eve;

        // Uninitialized_PausableImplBase - other setup
        $paused = false;

        // Uninitialized_PassThroughWalletImplBase - other setup
        $notFactory = users.eve;
        $passThrough = users.bob;
        $nextPassThrough = users.alice;

        /* _setUp(PassThroughWalletImpl.InitParams({owner: $owner, paused: $paused, passThrough: $passThrough)); */

        tokens = new address[](NUM_TOKENS);
        tokens[0] = ETH_ADDRESS;
        tokens[1] = address(mockERC20);
    }

    function _setUp(PassThroughWalletImpl.InitParams memory params_) internal virtual {
        $owner = params_.owner;
        $paused = params_.paused;
        $passThrough = params_.passThrough;
    }

    function _initParams() internal virtual returns (PassThroughWalletImpl.InitParams memory) {
        return PassThroughWalletImpl.InitParams({owner: $owner, paused: $paused, passThrough: $passThrough});
    }

    function _initialize() internal virtual override {
        $passThroughWallet = $passThroughWalletFactory.createPassThroughWallet(_initParams());
        $ownable = OwnableImplHarness(address($passThroughWallet));
        $pausable = PausableImplHarness(address($passThroughWallet));
    }

    /// -----------------------------------------------------------------------
    /// modifiers
    /// -----------------------------------------------------------------------

    modifier callerNotFactory(address notFactory_) {
        vm.assume(notFactory_ != address($passThroughWalletFactory));
        $notFactory = notFactory_;
        changePrank(notFactory_);
        _;
    }

    modifier callerFactory() {
        changePrank(address($passThroughWalletFactory));
        _;
    }
}

abstract contract Initialized_PassThroughWalletImplBase is
    Uninitialized_PassThroughWalletImplBase,
    Initialized_PausableImplBase
{
    function setUp() public virtual override(Uninitialized_PassThroughWalletImplBase, Initialized_PausableImplBase) {
        Uninitialized_PassThroughWalletImplBase.setUp();

        _initialize();
    }

    function _initialize()
        internal
        virtual
        override(Uninitialized_PassThroughWalletImplBase, Initialized_PausableImplBase)
    {
        Uninitialized_PassThroughWalletImplBase._initialize();
        _deal({account: address($passThroughWallet)});
    }
}

abstract contract Paused_Initialized_PassThroughWalletImplBase is Initialized_PassThroughWalletImplBase {
    function setUp() public virtual override {
        Uninitialized_PassThroughWalletImplBase.setUp();
        $paused = true;

        _initialize();
    }
}

abstract contract Unpaused_Initialized_PassThroughWalletImplBase is Initialized_PassThroughWalletImplBase {}
