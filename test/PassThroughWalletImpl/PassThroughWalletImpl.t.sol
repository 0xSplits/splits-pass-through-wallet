// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "splits-tests/base.t.sol";

import {
    Initialized_PausableImplBase,
    Initialized_PausableImplTest,
    Uninitialized_PausableImplBase,
    Uninitialized_PausableImplTest
} from "splits-tests/PausableImpl/PausableImpl.t.sol";

import {
    Initialized_PassThroughWalletImplBase,
    Paused_Initialized_PassThroughWalletImplBase,
    Uninitialized_PassThroughWalletImplBase,
    Unpaused_Initialized_PassThroughWalletImplBase
} from "./PassThroughWalletImplStateTree.sol";

/* import {PassThroughWalletFactory} from "../../src/PassThroughWalletFactory.sol"; */
import {PassThroughWalletImpl} from "../../src/PassThroughWalletImpl.sol";

// TODO
// refactor wallet
// layer in wallet
// ? more fuzzing ?
// ? forks ?
//   not sure how to bring forks & fuzzes together .. careful w rpc requests
// ? revisit best practices:
/* Define [rpc_endpoints] in the foundry.toml config file and use the forking cheatcodes. */
/* Access the RPC URL endpoint in your test with forge-std's stdChains.ChainName.rpcUrl. See the list of supported chains and expected config file aliases here. */
/* Always pin to a block so tests are deterministic and RPC responses are cached. */
// ? forks need different contracts for different networks anyway ?
// ? maybe only erc20 tests on fork using dai or usdc or both idk; woof just do both on both but then if it never gets done..?

contract Uninitialized_PassThroughWalletImplTest is
    Uninitialized_PausableImplTest,
    Uninitialized_PassThroughWalletImplBase
{
    function setUp() public virtual override(Uninitialized_PausableImplTest, Uninitialized_PassThroughWalletImplBase) {
        Uninitialized_PassThroughWalletImplBase.setUp();
    }

    function _initialize()
        internal
        virtual
        override(Uninitialized_PausableImplTest, Uninitialized_PassThroughWalletImplBase)
    {
        Uninitialized_PassThroughWalletImplBase._initialize();
    }

    /// -----------------------------------------------------------------------
    /// initializer
    /// -----------------------------------------------------------------------

    function test_revertWhen_callerNotFactory_initializer() public callerNotFactory($notFactory) {
        vm.expectRevert(Unauthorized.selector);
        $passThroughWalletImpl.initializer(_initParams());
    }

    function testFuzz_revertWhen_callerNotFactory_initializer(
        address caller_,
        PassThroughWalletImpl.InitParams calldata params_
    ) public callerNotFactory(caller_) {
        _setUp(params_);

        vm.expectRevert(Unauthorized.selector);
        $passThroughWalletImpl.initializer(_initParams());
    }

    function test_initializer_setsPassThrough() public {
        _initialize();
        assertEq($passThroughWallet.passThrough(), $passThrough);
    }

    function testFuzz_initializer_setsPassThrough(PassThroughWalletImpl.InitParams calldata params_) public {
        _setUp(params_);
        _initialize();

        assertEq($passThroughWallet.passThrough(), $passThrough);
    }

    // TODO: more fuzzing
}

contract Initialized_PassThroughWalletImplTest is
    Initialized_PausableImplTest,
    Initialized_PassThroughWalletImplBase
{
    function setUp() public virtual override(Initialized_PausableImplTest, Initialized_PassThroughWalletImplBase) {
        Initialized_PassThroughWalletImplBase.setUp();
    }

    function _initialize()
        internal
        virtual
        override(Initialized_PausableImplTest, Initialized_PassThroughWalletImplBase)
    {
        Initialized_PassThroughWalletImplBase._initialize();
    }

    /// -----------------------------------------------------------------------
    /// setPassThrough
    /// -----------------------------------------------------------------------

    function test_revertWhen_callerNotOwner_setPassThrough() public callerNotOwner($notOwner) {
        vm.expectRevert(Unauthorized.selector);
        $passThroughWallet.setPassThrough($notOwner);
    }

    function testFuzz_revertWhen_callerNotOwner_setPassThrough(address notOwner_, address nextPassThrough_)
        public
        callerNotOwner(notOwner_)
    {
        $nextPassThrough = nextPassThrough_;
        test_revertWhen_callerNotOwner_setPassThrough();
    }

    function test_setPassThrough_setsPassThrough() public callerOwner {
        $passThroughWallet.setPassThrough($nextPassThrough);
        assertEq($passThroughWallet.passThrough(), $nextPassThrough);
    }

    function testFuzz_setPassThrough_setsPassThrough(address nextPassThrough_) public callerOwner {
        $nextPassThrough = nextPassThrough_;
        test_setPassThrough_setsPassThrough();
    }

    function test_setPassThrough_emitsSetPassThrough() public callerOwner {
        _expectEmit();
        emit SetPassThrough($nextPassThrough);
        $passThroughWallet.setPassThrough($nextPassThrough);
    }

    function testFuzz_setPassThrough_emitsSetPassThrough(address nextPassThrough_) public callerOwner {
        $nextPassThrough = nextPassThrough_;
        test_setPassThrough_emitsSetPassThrough();
    }
}

contract Paused_Initialized_PassThroughWalletImplTest is
    Paused_Initialized_PassThroughWalletImplBase,
    Initialized_PassThroughWalletImplTest
{
    function setUp()
        public
        virtual
        override(Paused_Initialized_PassThroughWalletImplBase, Initialized_PassThroughWalletImplTest)
    {
        Paused_Initialized_PassThroughWalletImplBase.setUp();
    }

    function _initialize()
        internal
        virtual
        override(Initialized_PassThroughWalletImplBase, Initialized_PassThroughWalletImplTest)
    {
        Initialized_PassThroughWalletImplBase._initialize();
    }

    /// -----------------------------------------------------------------------
    /// passThroughTokens
    /// -----------------------------------------------------------------------

    function test_revertWhen_paused_passThroughTokens() public paused {
        vm.expectRevert(Paused.selector);
        $passThroughWallet.passThroughTokens(tokens);
    }

    function testFuzz_revertWhen_paused_passThroughTokens(address caller_, address[] memory tokens_) public paused {
        changePrank(caller_);
        vm.expectRevert(Paused.selector);
        $passThroughWallet.passThroughTokens(tokens_);
    }
}

contract Unpaused_Initialized_PassThroughWalletImplTest is
    Unpaused_Initialized_PassThroughWalletImplBase,
    Initialized_PassThroughWalletImplTest
{
    using TokenUtils for address;

    function setUp()
        public
        virtual
        override(Initialized_PassThroughWalletImplBase, Initialized_PassThroughWalletImplTest)
    {
        Initialized_PassThroughWalletImplBase.setUp();
    }

    function _initialize()
        internal
        virtual
        override(Initialized_PassThroughWalletImplBase, Initialized_PassThroughWalletImplTest)
    {
        Initialized_PassThroughWalletImplBase._initialize();
    }

    /// -----------------------------------------------------------------------
    /// passThroughTokens
    /// -----------------------------------------------------------------------

    function test_passThroughTokens_sendsTokensToPassThrough() public unpaused {
        uint256 length = tokens.length;
        uint256[] memory preBalancesWallet = new uint256[](length);
        uint256[] memory preBalancesBob = new uint256[](length);
        for (uint256 i; i < length; ++i) {
            address token = tokens[i];
            preBalancesWallet[i] = token._balanceOf(address($passThroughWallet));
            preBalancesBob[i] = token._balanceOf(users.bob);
        }

        $passThroughWallet.passThroughTokens(tokens);
        for (uint256 i; i < length; ++i) {
            address token = tokens[i];
            assertEq(token._balanceOf(users.bob), preBalancesBob[i] + preBalancesWallet[i]);
            assertEq(token._balanceOf(address($passThroughWallet)), 0);
        }
    }

    function testFuzz_passThroughTokens_sendsTokensToPassThrough(address caller_, uint96[NUM_TOKENS] calldata amounts_)
        public
        unpaused
    {
        changePrank(caller_);

        uint256 length = NUM_TOKENS;
        uint256[] memory preBalancesWallet = new uint256[](length);
        uint256[] memory preBalancesBob = new uint256[](length);
        for (uint256 i; i < length; i++) {
            address token = tokens[i];
            _deal({account: address($passThroughWallet), token: token, amount: uint256(amounts_[i])});
            preBalancesWallet[i] = token._balanceOf(address($passThroughWallet));
            preBalancesBob[i] = token._balanceOf(users.bob);
        }

        $passThroughWallet.passThroughTokens(tokens);
        for (uint256 i; i < length; ++i) {
            address token = tokens[i];
            assertEq(token._balanceOf(users.bob), preBalancesBob[i] + preBalancesWallet[i]);
            assertEq(token._balanceOf(address($passThroughWallet)), 0);
        }
    }

    function test_passThroughTokens_returnsAmounts() public unpaused {
        uint256 length = tokens.length;
        uint256[] memory preBalancesWallet = new uint256[](length);
        for (uint256 i; i < length; ++i) {
            preBalancesWallet[i] = tokens[i]._balanceOf(address($passThroughWallet));
        }

        uint256[] memory amounts = $passThroughWallet.passThroughTokens(tokens);
        for (uint256 i; i < length; ++i) {
            assertEq(amounts[i], preBalancesWallet[i]);
        }
    }

    function testFuzz_passThroughTokens_returnsAmounts(address caller_, uint96[NUM_TOKENS] calldata amounts_)
        public
        unpaused
    {
        changePrank(caller_);

        uint256 length = NUM_TOKENS;
        for (uint256 i; i < length; i++) {
            _deal({account: address($passThroughWallet), token: tokens[i], amount: uint256(amounts_[i])});
        }

        uint256[] memory amounts = $passThroughWallet.passThroughTokens(tokens);
        for (uint256 i; i < length; ++i) {
            assertEq(amounts[i], amounts_[i]);
        }
    }

    function test_passThroughTokens_emitsPassThrough() public unpaused {
        uint256 length = tokens.length;
        uint256[] memory preBalancesWallet = new uint256[](length);
        for (uint256 i; i < length; ++i) {
            preBalancesWallet[i] = tokens[i]._balanceOf(address($passThroughWallet));
        }

        _expectEmit();
        emit PassThrough(tokens, preBalancesWallet);
        $passThroughWallet.passThroughTokens(tokens);
    }

    function testFuzz_passThroughTokens_emitsPassThrough(address caller_, uint96[NUM_TOKENS] calldata amounts_)
        public
        unpaused
    {
        changePrank(caller_);

        uint256 length = NUM_TOKENS;
        uint256[] memory amounts = new uint256[](length);
        for (uint256 i; i < length; i++) {
            amounts[i] = uint256(amounts_[i]);
            _deal({account: address($passThroughWallet), token: tokens[i], amount: amounts[i]});
        }

        _expectEmit();
        emit PassThrough(tokens, amounts);
        $passThroughWallet.passThroughTokens(tokens);
    }
}
