// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "splits-tests/base.t.sol";

import {PassThroughWalletImpl, PassThroughWalletFactory} from "src/PassThroughWalletFactory.sol";

contract PassThroughWalletFactoryTest is BaseTest {
    event CreatePassThroughWallet(
        PassThroughWalletImpl indexed passThroughWallet, PassThroughWalletImpl.InitParams params
    );

    PassThroughWalletFactory public passThroughWalletFactory;
    PassThroughWalletImpl public passThroughWalletImpl;

    function setUp() public virtual override {
        super.setUp();

        passThroughWalletFactory = new PassThroughWalletFactory();
        passThroughWalletImpl = passThroughWalletFactory.passThroughWalletImpl();
    }

    /// -----------------------------------------------------------------------
    /// tests - basic
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// tests - basic - createPassThroughWallet
    /// -----------------------------------------------------------------------

    function test_createPassThroughWallet_callsInitializer() public {
        PassThroughWalletImpl.InitParams memory params =
            PassThroughWalletImpl.InitParams({owner: users.alice, paused: false, passThrough: users.bob});

        vm.expectCall({
            callee: address(passThroughWalletImpl),
            msgValue: 0 ether,
            data: abi.encodeCall(PassThroughWalletImpl.initializer, (params))
        });
        passThroughWalletFactory.createPassThroughWallet(params);
    }

    function test_createPassThroughWallet_emitsEvent() public {
        PassThroughWalletImpl.InitParams memory params =
            PassThroughWalletImpl.InitParams({owner: users.alice, paused: false, passThrough: users.bob});

        // don't check first topic which is new address
        vm.expectEmit({checkTopic1: false, checkTopic2: true, checkTopic3: true, checkData: true});
        emit CreatePassThroughWallet(passThroughWalletImpl, params);
        passThroughWalletFactory.createPassThroughWallet(params);
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// tests - fuzz - createPassThroughWallet
    /// -----------------------------------------------------------------------

    function testFuzz_createPassThroughWallet_callsInitializer(PassThroughWalletImpl.InitParams memory params) public {
        vm.expectCall({
            callee: address(passThroughWalletImpl),
            msgValue: 0 ether,
            data: abi.encodeCall(PassThroughWalletImpl.initializer, (params))
        });
        passThroughWalletFactory.createPassThroughWallet(params);
    }

    function testFuzz_createPassThroughWallet_emitsEvent(PassThroughWalletImpl.InitParams memory params) public {
        // don't check first topic which is new address
        vm.expectEmit({checkTopic1: false, checkTopic2: true, checkTopic3: true, checkData: true});
        emit CreatePassThroughWallet(passThroughWalletImpl, params);
        passThroughWalletFactory.createPassThroughWallet(params);
    }
}
