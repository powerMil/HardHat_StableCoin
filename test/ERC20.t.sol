// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console2, StdStyle, StdCheats} from "forge-std/Test.sol";

import {ERC20} from "../contracts/ERC20.sol";

contract BaseSetup is ERC20, Test {
    address internal alice;
    address internal bob;

    constructor() ERC20("name", "SYM", 18) {}

    function setUp() public virtual {
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        console2.log(StdStyle.blue("When Alice has a 300 tokens"));

        //_mint(alice,300e18);

        deal(address(this), alice, 300e18);
        // console2.log("balance",this.balanceOf(alice));
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        vm.prank(from);
        return this.transfer(to, amount);
    }
}

//Tests for transfer function- remove comments to execute

/*contract ERC20TransferTest is BaseSetup{


   function setUp() public override {
      BaseSetup.setUp();
     
      //console2.log(StdStyle.red("my red string"));
       //console2.log(StdStyle.bold("my bold string"));
        //console2.log(StdStyle.underline("my underline string"));
   } 

   function testTransfersTokenCorrectly() public {
      vm.prank(alice);
     bool success= this.transfer(bob,100e18);
     assertTrue(success);

     //assertEq(this.balanceOf(alice), 100e18);
     //assertEq(this.balanceOf(bob), 100e18);
     assertEqDecimal(this.balanceOf(alice), 100e18,decimals);
     assertEqDecimal(this.balanceOf(bob), 100e18,decimals);
      

   }

   function testCannotTransferMoreThanBalance() public {
     vm.prank(alice);
     vm.expectRevert("ERC20: Insufficient sender balance");
     this.transfer(bob,100e18);

   }

   function testEmitsTransferEvent() public {

      vm.expectEmit(true,false,true,false);
      emit Transfer(alice,bob,200e18);

       vm.prank(alice);
       this.transfer(bob,100e18);

     }

 }*/
contract ERC20TransferFromTest is BaseSetup {
    function setUp() public override {
        BaseSetup.setUp();
    }

    function testTransfersFromTokenCorrectly() public {
        bool success = transferFrom(alice, bob, 100e18);
        console2.log("balance_alice", this.balanceOf(alice));
        console2.log("balance_bob", this.balanceOf(bob));

        assertTrue(success);

        assertEqDecimal(this.balanceOf(alice), 200e18, decimals);
        assertEqDecimal(this.balanceOf(bob), 100e18, decimals);
    }

    function testCannotTransferFromMoreThanBalance() public {
        vm.prank(alice);
        vm.expectRevert("ERC20: Insufficient sender balance");
        transferFrom(alice, bob, 400e18);
    }
}
