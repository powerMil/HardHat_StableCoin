import { ethers } from "hardhat";


async function main() {




    const ERC20 = await ethers.getContractFactory("ERC20")
    const [contractAddress] = await ethers.getSigners();
    //const con_address = await ethers.getContractAt("ERC20", contractAddress.address);
    const erc20 = await ERC20.deploy("Name", "SYM", 18);
    console.log("ERC2O deployed to ", contractAddress.address);

}

main().catch((error) => { // calling the main function and executing it with an error catch
    console.error(error)
    process.exitCode = 1;
})