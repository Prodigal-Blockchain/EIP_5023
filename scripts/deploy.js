const { Contract, ContractFactory, utils, BigNumber } = require("ethers");
require("dotenv").config;

const { ethers } = require("hardhat");

async function main() {
  const ownerPrivateKey = process.env.PRIVATE_KEY;
  const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
  console.log(ownerPrivateKey, provider);
  const owner = new ethers.Wallet(ownerPrivateKey, provider);
  //Deploy AssetRegistration  contract
  const Asset = await ethers.getContractFactory("Asset");
  const AssetArtifact = await Asset.deploy();
  await AssetArtifact.waitForDeployment();
  console.log("Asset:", AssetArtifact.target);

  //Verify the contracts
  await hre.run("verify:verify", {
    address: "0x91fa8663653e932dAf2f5bB556d8A0a33Dc2a2e9",
    constructorArguments: [],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
