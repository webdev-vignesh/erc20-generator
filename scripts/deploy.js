const hre = require("hardhat");
const { ethers } = require("hardhat/internal/lib/hardhat-lib");

const tokens = (_number) => {
    return ethers.utils.parseUnits(_number.toString(), "ether");
}

async function main() {
    // ERC20Generator
    const _tokenName = "FAST SHINE";
    const _tokenSymbol = "FS";
    const _initialSupply = tokens(1000);

    const ERC20Generator = await hre.ethers.getContractFactory("ERC20Generator");
    const erc20Generator = await ERC20Generator.deploy(
        _initialSupply,
        _tokenName,
        _tokenSymbol
    );
    await erc20Generator.deployed();
    console.log(`ERC20Generator: ${erc20Generator.address}`);

    // LookUpContract
    const LookUpContract = await hre.ethers.getContractFactory("LookUpContract");
    const lookUpContract = await LookUpContract.deploy();
    await lookUpContract.deployed();
    console.log(`LookUpContract: ${lookUpContract.address}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
})