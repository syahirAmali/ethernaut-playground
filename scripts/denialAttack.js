
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
  let provider = ethers.provider;
  const Vault = await hre.ethers.getContractFactory("AttackDenial");
  const attack = await Vault.deploy();

  await attack.deployed();

  console.log("attack deployed to:", attack.address);

}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
