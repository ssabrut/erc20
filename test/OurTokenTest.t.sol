// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "script/DeployOurToken.s.sol";
import {OurToken} from "src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ot;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ot = deployer.run();

        vm.prank(msg.sender);
        ot.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public view {
        assertEq(STARTING_BALANCE, ot.balanceOf(bob));
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;

        // Bob approve Alice to spend token on her behalf
        vm.prank(bob);
        ot.approve(alice, initialAllowance);

        uint256 transferAmount = 500;
        vm.prank(alice);
        ot.transferFrom(bob, alice, transferAmount);

        assertEq(ot.balanceOf(alice), transferAmount);
        assertEq(ot.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransfer() public {
        uint256 amount = 50;
        uint256 ownerBalanceBefore = ot.balanceOf(msg.sender);

        vm.prank(msg.sender);
        ot.transfer(bob, amount);

        assertEq(ot.balanceOf(msg.sender), ownerBalanceBefore - amount);
        assertEq(ot.balanceOf(bob), amount);
    }

    function testTransferInsufficientBalance() public {
        uint256 amount = 100;
        vm.prank(alice);
        vm.expectRevert();
        ot.transfer(bob, amount);
    }
}
