// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "splits-tests/base.t.sol";

import {PassThroughWalletImpl, PassThroughWalletFactory} from "../src/PassThroughWalletFactory.sol";

contract PassThroughWalletImplTest is BaseTest {
    using TokenUtils for address;

    error Unauthorized();
    error Paused();

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event SetPassThrough(address passThrough);
    event PassThrough(address[] tokens, uint256[] amounts);

    uint256 constant NUM_TOKENS = 2;

    PassThroughWalletFactory passThroughWalletFactory;
    PassThroughWalletImpl passThroughWalletImpl;
    PassThroughWalletImpl passThroughWallet;

    PassThroughWalletImpl.InitParams initParams;

    address[] tokens;

    function setUp() public virtual override {
        super.setUp();

        passThroughWalletFactory = new PassThroughWalletFactory();
        passThroughWalletImpl = passThroughWalletFactory.passThroughWalletImpl();

        initParams = PassThroughWalletImpl.InitParams({owner: users.alice, paused: false, passThrough: users.bob});
        passThroughWallet = passThroughWalletFactory.createPassThroughWallet(initParams);
        _deal({account: address(passThroughWallet)});

        tokens = new address[](NUM_TOKENS);
        tokens[0] = ETH_ADDRESS;
        tokens[1] = address(mockERC20);
    }

    /// -----------------------------------------------------------------------
    /// modifiers
    /// -----------------------------------------------------------------------

    modifier callerFactory() {
        _;
    }

    modifier callerOwner() {
        _;
    }

    modifier unpaused() {
        _;
    }

    /// -----------------------------------------------------------------------
    /// tests - basic
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// tests - basic - initializer
    /// -----------------------------------------------------------------------

    function test_revertWhen_callerNotFactory_initializer() public {
        vm.expectRevert(Unauthorized.selector);
        passThroughWalletImpl.initializer(initParams);

        vm.expectRevert(Unauthorized.selector);
        passThroughWallet.initializer(initParams);
    }

    function test_initializer_setsOwner() public callerFactory {
        vm.prank(address(passThroughWalletFactory));
        passThroughWallet.initializer(initParams);
        assertEq(passThroughWallet.owner(), initParams.owner);
    }

    function test_initializer_setsPausable() public callerFactory {
        vm.prank(address(passThroughWalletFactory));
        passThroughWallet.initializer(initParams);
        assertEq(passThroughWallet.paused(), initParams.paused);
    }

    function test_initializer_setsPassThrough() public callerFactory {
        vm.prank(address(passThroughWalletFactory));
        passThroughWallet.initializer(initParams);
        assertEq(passThroughWallet.passThrough(), initParams.passThrough);
    }

    function test_initializer_emitsOwnershipTransferred() public callerFactory {
        vm.prank(address(passThroughWalletFactory));
        _expectEmit();
        emit OwnershipTransferred(address(0), initParams.owner);
        passThroughWallet.initializer(initParams);
    }

    /// -----------------------------------------------------------------------
    /// tests - basic - setPassThrough
    /// -----------------------------------------------------------------------

    function test_revertWhen_callerNotOwner_setPassThrough() public {
        vm.expectRevert(Unauthorized.selector);
        passThroughWallet.setPassThrough(users.eve);
    }

    function test_setPassThrough_setsPassThrough() public callerOwner {
        vm.prank(initParams.owner);
        passThroughWallet.setPassThrough(users.eve);
        assertEq(passThroughWallet.passThrough(), users.eve);
    }

    function test_setPassThrough_emitsSetPassThrough() public callerOwner {
        vm.prank(initParams.owner);
        vm.expectEmit();
        emit SetPassThrough(users.eve);
        passThroughWallet.setPassThrough(users.eve);
    }

    /// -----------------------------------------------------------------------
    /// tests - basic - passThroughTokens
    /// -----------------------------------------------------------------------

    function test_revertWhen_paused_passThroughTokens() public {
        vm.prank(initParams.owner);
        passThroughWallet.setPaused(true);

        vm.expectRevert(Paused.selector);
        passThroughWallet.passThroughTokens(tokens);
    }

    function test_passThroughTokens_sendsTokensToPassThrough() public unpaused {
        uint256 length = tokens.length;
        uint256[] memory preBalancesWallet = new uint256[](length);
        uint256[] memory preBalancesBob = new uint256[](length);
        for (uint256 i; i < length; ++i) {
            preBalancesWallet[i] = tokens[i]._balanceOf(address(passThroughWallet));
            preBalancesBob[i] = tokens[i]._balanceOf(users.bob);
        }

        passThroughWallet.passThroughTokens(tokens);
        for (uint256 i; i < length; ++i) {
            assertEq(tokens[i]._balanceOf(users.bob), preBalancesBob[i] + preBalancesWallet[i]);
        }
    }

    function test_passThroughTokens_returnsAmounts()
        public
        unpaused
    {
        uint256 length = tokens.length;
        uint256[] memory preBalancesWallet = new uint256[](length);
        for (uint256 i; i < length; ++i) {
            preBalancesWallet[i] = tokens[i]._balanceOf(address(passThroughWallet));
        }

        uint256[] memory amounts = passThroughWallet.passThroughTokens(tokens);
        for (uint256 i; i < length; ++i) {
            assertEq(amounts[i], preBalancesWallet[i]);
        }
    }

    function test_passThroughTokens_emitsPassThrough() public unpaused {
        uint256 length = tokens.length;
        uint256[] memory preBalancesWallet = new uint256[](length);
        for (uint256 i; i < length; ++i) {
            preBalancesWallet[i] = tokens[i]._balanceOf(address(passThroughWallet));
        }

        _expectEmit();
        emit PassThrough(tokens, preBalancesWallet);
        passThroughWallet.passThroughTokens(tokens);
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// tests - fuzz - initializer
    /// -----------------------------------------------------------------------

    function testFuzz_revertWhen_callerNotFactory_initializer(address caller_) public {
        vm.assume(caller_ != address(passThroughWalletFactory));
        vm.prank(caller_);

        vm.expectRevert(Unauthorized.selector);
        passThroughWalletImpl.initializer(initParams);

        vm.expectRevert(Unauthorized.selector);
        passThroughWallet.initializer(initParams);
    }

    function testFuzz_initializer_setsOwner(PassThroughWalletImpl.InitParams calldata params_) public callerFactory {
        vm.prank(address(passThroughWalletFactory));
        passThroughWallet.initializer(params_);
        assertEq(passThroughWallet.owner(), params_.owner);
    }

    function testFuzz_initializer_setsPausable(PassThroughWalletImpl.InitParams calldata params_)
        public
        callerFactory
    {
        vm.prank(address(passThroughWalletFactory));
        passThroughWallet.initializer(params_);
        assertEq(passThroughWallet.paused(), params_.paused);
    }

    function testFuzz_initializer_setsPassThrough(PassThroughWalletImpl.InitParams calldata params_)
        public
        callerFactory
    {
        vm.prank(address(passThroughWalletFactory));
        passThroughWallet.initializer(params_);
        assertEq(passThroughWallet.passThrough(), params_.passThrough);
    }

    function testFuzz_initializer_emitsOwnershipTransferred(PassThroughWalletImpl.InitParams calldata params_)
        public
        callerFactory
    {
        vm.prank(address(passThroughWalletFactory));
        vm.expectEmit();
        emit OwnershipTransferred(address(0), params_.owner);
        passThroughWallet.initializer(params_);
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz - setPassThrough
    /// -----------------------------------------------------------------------

    function testFuzz_revertWhen_callerNotOwner_setPassThrough(address caller_, address passThrough_) public {
        vm.assume(caller_ != initParams.owner);
        vm.prank(caller_);
        vm.expectRevert(Unauthorized.selector);
        passThroughWallet.setPassThrough(passThrough_);
    }

    function testFuzz_setPassThrough_setsPassThrough(address passThrough_) public callerOwner {
        vm.prank(initParams.owner);
        passThroughWallet.setPassThrough(passThrough_);
        assertEq(passThroughWallet.passThrough(), passThrough_);
    }

    function testFuzz_setPassThrough_emitsSetPassThrough(address passThrough_) public callerOwner {
        vm.prank(initParams.owner);
        vm.expectEmit();
        emit SetPassThrough(passThrough_);
        passThroughWallet.setPassThrough(passThrough_);
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz - passThroughTokens
    /// -----------------------------------------------------------------------

    function testFuzz_passThroughTokens_sendsTokensToPassThrough(uint96[NUM_TOKENS] calldata amounts_)
        public
        unpaused
    {
        uint256 length = NUM_TOKENS;
        uint256[] memory preBalancesWallet = new uint256[](length);
        uint256[] memory preBalancesBob = new uint256[](length);
        for (uint256 i; i < length; i++) {
            address token = tokens[i];
            if (token._isETH()) {
                vm.deal({account: address(passThroughWallet), newBalance: amounts_[0]});
            } else {
                deal({token: token, to: address(passThroughWallet), give: amounts_[1]});
            }
            preBalancesWallet[i] = tokens[i]._balanceOf(address(passThroughWallet));
            preBalancesBob[i] = tokens[i]._balanceOf(users.bob);
        }

        passThroughWallet.passThroughTokens(tokens);
        for (uint256 i; i < length; ++i) {
            assertEq(tokens[i]._balanceOf(users.bob), preBalancesBob[i] + preBalancesWallet[i]);
        }
    }

    function testFuzz_passThroughTokens_returnsAmounts(uint96[NUM_TOKENS] calldata amounts_)
        public
        unpaused
    {
        uint256 length = NUM_TOKENS;
        for (uint256 i; i < length; i++) {
            address token = tokens[i];
            if (token._isETH()) {
                vm.deal({account: address(passThroughWallet), newBalance: amounts_[0]});
            } else {
                deal({token: token, to: address(passThroughWallet), give: amounts_[1]});
            }
        }

        uint256[] memory amounts = passThroughWallet.passThroughTokens(tokens);
        for (uint256 i; i < length; ++i) {
            assertEq(amounts[i], amounts_[i]);
        }
    }

    function testFuzz_passThroughTokens_emitsPassThrough(uint96[NUM_TOKENS] calldata amounts_) public unpaused {
        uint256 length = NUM_TOKENS;
        uint256[] memory amounts = new uint256[](length);
        for (uint256 i; i < length; i++) {
            amounts[i] = uint256(amounts_[i]);
            address token = tokens[i];
            if (token._isETH()) {
                vm.deal({account: address(passThroughWallet), newBalance: amounts_[0]});
            } else {
                deal({token: token, to: address(passThroughWallet), give: amounts_[1]});
            }
        }

        _expectEmit();
        emit PassThrough(tokens, amounts);
        passThroughWallet.passThroughTokens(tokens);
    }
}
