// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "splits-tests/base.t.sol";
import {LibCloneBase} from "splits-tests/LibClone.t.sol";

import {PassThroughWalletFactory} from "../src/PassThroughWalletFactory.sol";
import {PassThroughWalletImpl} from "../src/PassThroughWalletImpl.sol";

contract PassThroughWalletFactoryTest is BaseTest, LibCloneBase {
    event CreatePassThroughWallet(
        PassThroughWalletImpl indexed passThroughWallet, PassThroughWalletImpl.InitParams params
    );

    PassThroughWalletFactory passThroughWalletFactory;
    PassThroughWalletImpl passThroughWalletImpl;
    PassThroughWalletImpl passThroughWallet;

    PassThroughWalletImpl.InitParams params;

    function setUp() public virtual override(BaseTest, LibCloneBase) {
        BaseTest.setUp();

        passThroughWalletFactory = new PassThroughWalletFactory();
        passThroughWalletImpl = passThroughWalletFactory.passThroughWalletImpl();

        params = PassThroughWalletImpl.InitParams({owner: users.alice, paused: false, passThrough: users.bob});
        passThroughWallet = passThroughWalletFactory.createPassThroughWallet(params);

        // setup LibCloneBase
        impl = address(passThroughWalletImpl);
        clone = address(passThroughWallet);
        amount = 1 ether;
        data = "Hello, World!";
    }

    /// -----------------------------------------------------------------------
    /// createPassThroughWallet
    /// -----------------------------------------------------------------------

    function test_createPassThroughWallet_callsInitializer() public {
        vm.expectCall({
            callee: address(passThroughWalletImpl),
            msgValue: 0 ether,
            data: abi.encodeCall(PassThroughWalletImpl.initializer, (params))
        });
        passThroughWalletFactory.createPassThroughWallet(params);
    }

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

    function test_createPassThroughWallet_emitsCreatePassThroughWallet() public {
        address expectedAddress = _predictNextAddressFrom(address(passThroughWalletFactory));
        _expectEmit();
        emit CreatePassThroughWallet(PassThroughWalletImpl(expectedAddress), params);
        passThroughWalletFactory.createPassThroughWallet(params);
    }

    function testFuzz_createPassThroughWallet_emitsCreatePassThroughWallet(
        PassThroughWalletImpl.InitParams calldata params_
    ) public {
        address expectedAddress = _predictNextAddressFrom(address(passThroughWalletFactory));
        _expectEmit();
        emit CreatePassThroughWallet(PassThroughWalletImpl(expectedAddress), params_);
        passThroughWalletFactory.createPassThroughWallet(params_);
    }

    function testFuzz_createPassThroughWallet_createsClone_code(PassThroughWalletImpl.InitParams calldata params_)
        public
    {
        clone = address(passThroughWalletFactory.createPassThroughWallet(params_));

        test_clone_code();
    }

    function testFuzz_createPassThroughWallet_createsClone_canReceiveETH(
        PassThroughWalletImpl.InitParams calldata params_,
        uint96 amount_
    ) public {
        clone = address(passThroughWalletFactory.createPassThroughWallet(params_));
        amount = amount_;

        test_clone_canReceiveETH();
    }

    function testFuzz_createPassThroughWallet_createsClone_emitsReceiveETH(
        PassThroughWalletImpl.InitParams calldata params_,
        uint96 amount_
    ) public {
        clone = address(passThroughWalletFactory.createPassThroughWallet(params_));
        amount = amount_;

        test_clone_emitsReceiveETH();
    }

    function testFuzz_createPassThroughWallet_createsClone_canDelegateCall(
        PassThroughWalletImpl.InitParams calldata params_,
        bytes calldata data_
    ) public {
        vm.assume(data_.length > 0);

        clone = address(passThroughWalletFactory.createPassThroughWallet(params_));
        data = data_;

        test_clone_canDelegateCall();
    }
}
