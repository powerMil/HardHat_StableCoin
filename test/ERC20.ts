import { ethers, network } from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
//import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
//import { ERC20Mock } from "../typechain-types";




describe("ERC20", function () {

    //let alice: SignerWithAddress, bob: SignerWithAddress, erc20Token: ERC20Mock; // define let variables with their types

    // this.beforeEach(async function () {
    async function deployAndMockERC20() {

        const [alice, bob] = await ethers.getSigners();
        const ERC20 = await ethers.getContractFactory("ERC20Mock");
        const erc20Token = await ERC20.deploy("Name", "SYM", 18); // in order to retrieve the type of erc20Token u can add let in front of the variable and u can get the type. Then remove let keyword



        await erc20Token.mint(alice.address, 300);
        await network.provider.send("evm_mine");

        return { alice, bob, erc20Token };

    }
    it("transfers token correctly", async function () {
        const { alice, bob, erc20Token } = await loadFixture(deployAndMockERC20);
        //const addresses =await ethers.getSigners();

        //const bob=addresses[0];


        console.log("Alice balance here is:", (await erc20Token.balanceOf(alice.address)).toString());


        await expect(await erc20Token.transfer(bob.address, 100)).to.changeTokenBalances(erc20Token, [alice, bob], [-100, 100]);

        /* const aliceBalance= await erc20Token.balanceOf(alice.address);
         const bobBalance= await erc20Token.balanceOf(bob.address);
         expect(aliceBalance).to.equals(200);
         expect(bobBalance).to.equals(100);*/

        await expect(erc20Token.connect(bob).transfer(alice.address, 50)).to.changeTokenBalances(erc20Token, [alice, bob], [50, -50]);


    });

    it("should revert if sender has insufficient balance", async function () {
        const { alice, bob, erc20Token } = await loadFixture(deployAndMockERC20);

        console.log("Alice balance here is:", (await erc20Token.balanceOf(alice.address)).toString());
        await expect(erc20Token.transfer(bob.address, 400)).to.be.revertedWith("ERC20: Insufficient sender balance"); // u expecting the transfer to be reverted with exact error msg match as in ERC20.sol transfer function


    });

    it("should emit Transfer event on transfers", async function () {
        const { alice, bob, erc20Token } = await loadFixture(deployAndMockERC20);

        console.log("Alice balance here is:", (await erc20Token.balanceOf(alice.address)).toString());
        await expect(erc20Token.transfer(bob.address, 200)).to.emit(erc20Token, "Transfer").withArgs(alice.address, bob.address, 200);// test an emit event from the contract with arguments
    });
});