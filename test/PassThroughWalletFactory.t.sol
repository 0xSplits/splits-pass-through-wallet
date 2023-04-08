// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "splits-tests/base.t.sol";

import {PassThroughWalletImpl, PassThroughWalletFactory} from "../src/PassThroughWalletFactory.sol";

contract PassThroughWalletFactoryTest is BaseTest {
    event CreatePassThroughWallet(
        PassThroughWalletImpl indexed passThroughWallet, PassThroughWalletImpl.InitParams params
    );

    PassThroughWalletFactory passThroughWalletFactory;
    PassThroughWalletImpl passThroughWalletImpl;

    PassThroughWalletImpl.InitParams params;

    function setUp() public virtual override {
        super.setUp();

        passThroughWalletFactory = new PassThroughWalletFactory();
        passThroughWalletImpl = passThroughWalletFactory.passThroughWalletImpl();

        params = PassThroughWalletImpl.InitParams({owner: users.alice, paused: false, passThrough: users.bob});
    }

    /// -----------------------------------------------------------------------
    /// tests - basic
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// tests - basic - createPassThroughWallet
    /// -----------------------------------------------------------------------

    function test_createPassThroughWallet_callsInitializer() public {
        vm.expectCall({
            callee: address(passThroughWalletImpl),
            msgValue: 0 ether,
            data: abi.encodeCall(PassThroughWalletImpl.initializer, (params))
        });
        passThroughWalletFactory.createPassThroughWallet(params);
    }

    function test_createPassThroughWallet_emitsCreatePassThroughWallet() public {
        address expectedAddress = _predictNextAddressFrom(address(passThroughWalletFactory));
        _expectEmit();
        emit CreatePassThroughWallet(PassThroughWalletImpl(expectedAddress), params);
        passThroughWalletFactory.createPassThroughWallet(params);
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// tests - fuzz - createPassThroughWallet
    /// -----------------------------------------------------------------------

    function testFuzz_createPassThroughWallet_callsInitializer(PassThroughWalletImpl.InitParams calldata params_)
        public
    {
        vm.expectCall({
            callee: address(passThroughWalletImpl),
            msgValue: 0 ether,
            data: abi.encodeCall(PassThroughWalletImpl.initializer, (params_))
        });
        passThroughWalletFactory.createPassThroughWallet(params_);
    }

    function testFuzz_createPassThroughWallet_emitsCreatePassThroughWallet(
        PassThroughWalletImpl.InitParams calldata params_
    ) public {
        address expectedAddress = _predictNextAddressFrom(address(passThroughWalletFactory));
        _expectEmit();
        emit CreatePassThroughWallet(PassThroughWalletImpl(expectedAddress), params_);
        passThroughWalletFactory.createPassThroughWallet(params_);
    }
}
