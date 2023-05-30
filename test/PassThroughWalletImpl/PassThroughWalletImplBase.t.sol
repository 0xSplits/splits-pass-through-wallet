// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "splits-tests/base.t.sol";

import {
    Initialized_PausableImplBase,
    PausableImplHarness,
    Uninitialized_PausableImplBase
} from "splits-tests/PausableImpl/PausableImplBase.t.sol";
import {
    Initialized_WalletImplBase,
    WalletImpl,
    WalletImplHarness,
    Uninitialized_WalletImplBase
} from "splits-tests/WalletImpl/WalletImplBase.t.sol";
import {OwnableImplHarness, Uninitialized_OwnableImplBase} from "splits-tests/OwnableImpl/OwnableImplBase.t.sol";

import {PassThroughWalletFactory} from "../../src/PassThroughWalletFactory.sol";
import {PassThroughWalletImpl} from "../../src/PassThroughWalletImpl.sol";

// State tree
//  Uninitialized
//  Initialized
//   Paused
//   Unpaused

abstract contract Uninitialized_PassThroughWalletImplBase is
    Uninitialized_PausableImplBase,
    Uninitialized_WalletImplBase
{
    event SetPassThrough(address passThrough);
    event PassThrough(address indexed passThrough, address[] tokens, uint256[] amounts);

    PassThroughWalletFactory $passThroughWalletFactory;
    PassThroughWalletImpl $passThroughWallet;

    address $passThrough;
    address $nextPassThrough;
    address $notFactory;

    uint256 constant NUM_TOKENS = 2;
    address[] $tokens;

    function setUp() public virtual override(Uninitialized_PausableImplBase, Uninitialized_WalletImplBase) {
        Uninitialized_OwnableImplBase.setUp();

        $passThroughWalletFactory = new PassThroughWalletFactory();

        $calls.push(WalletImpl.Call({to: users.alice, value: 1 ether, data: "0x123456789"}));

        $erc1155Ids.push(0);
        $erc1155Ids.push(1);
        $erc1155Amounts.push(1);
        $erc1155Amounts.push(2);

        address[NUM_TOKENS] memory tokens = [ETH_ADDRESS, address(mockERC20)];

        _setUpPassThroughWalletImplState({
            passThroughWallet_: address($passThroughWalletFactory.passThroughWalletImpl()),
            paused_: false,
            calls_: $calls,
            erc721Amount_: 1,
            erc1155Id_: 0,
            erc1155Amount_: 1,
            erc1155Data_: "",
            erc1155Ids_: $erc1155Ids,
            erc1155Amounts_: $erc1155Amounts,
            passThrough_: users.bob,
            nextPassThrough_: users.alice,
            notFactory_: users.eve,
            tokens_: tokens
        });
    }

    function _setUpPassThroughWalletImplState(
        address passThroughWallet_,
        bool paused_,
        WalletImpl.Call[] memory calls_,
        uint256 erc721Amount_,
        uint256 erc1155Id_,
        uint256 erc1155Amount_,
        bytes memory erc1155Data_,
        uint256[] memory erc1155Ids_,
        uint256[] memory erc1155Amounts_,
        address passThrough_,
        address nextPassThrough_,
        address notFactory_,
        address[NUM_TOKENS] memory tokens_
    ) internal virtual {
        _setUpPausableImplState({pausable_: passThroughWallet_, paused_: paused_});
        _setUpWalletImplState({
            wallet_: passThroughWallet_,
            calls_: calls_,
            erc721Amount_: erc721Amount_,
            erc1155Id_: erc1155Id_,
            erc1155Amount_: erc1155Amount_,
            erc1155Data_: erc1155Data_,
            erc1155Ids_: erc1155Ids_,
            erc1155Amounts_: erc1155Amounts_
        });

        $passThroughWallet = PassThroughWalletImpl(passThroughWallet_);
        $notFactory = notFactory_;
        $passThrough = passThrough_;
        $nextPassThrough = nextPassThrough_;

        delete $tokens;
        for (uint256 i = 0; i < NUM_TOKENS; i++) {
            $tokens.push(tokens_[i]);
        }
    }

    function _setUpPassThroughWalletParams(PassThroughWalletImpl.InitParams memory params_) internal virtual {
        $owner = params_.owner;
        $paused = params_.paused;
        $passThrough = params_.passThrough;
    }

    function _initParams() internal virtual returns (PassThroughWalletImpl.InitParams memory) {
        return PassThroughWalletImpl.InitParams({owner: $owner, paused: $paused, passThrough: $passThrough});
    }

    function _initialize() internal virtual override(Uninitialized_PausableImplBase, Uninitialized_WalletImplBase) {
        $passThroughWallet = $passThroughWalletFactory.createPassThroughWallet(_initParams());
        $ownable = OwnableImplHarness(address($passThroughWallet));
        $pausable = PausableImplHarness(address($passThroughWallet));
        $wallet = WalletImplHarness(address($passThroughWallet));
    }

    /// -----------------------------------------------------------------------
    /// modifiers
    /// -----------------------------------------------------------------------

    modifier callerNotFactory(address notFactory_) {
        vm.assume(notFactory_ != address($passThroughWalletFactory));
        $notFactory = notFactory_;
        vm.startPrank(notFactory_);
        _;
    }

    modifier callerFactory() {
        vm.startPrank(address($passThroughWalletFactory));
        _;
    }
}

abstract contract Initialized_PassThroughWalletImplBase is
    Uninitialized_PassThroughWalletImplBase,
    Initialized_PausableImplBase,
    Initialized_WalletImplBase
{
    function setUp()
        public
        virtual
        override(Uninitialized_PassThroughWalletImplBase, Initialized_PausableImplBase, Initialized_WalletImplBase)
    {
        Uninitialized_PassThroughWalletImplBase.setUp();
        _initialize();
    }

    function _initialize()
        internal
        virtual
        override(Uninitialized_PassThroughWalletImplBase, Initialized_PausableImplBase, Initialized_WalletImplBase)
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
