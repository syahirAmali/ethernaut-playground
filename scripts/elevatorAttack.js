
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
  let provider = ethers.provider;
  const elevator = await hre.ethers.getContractFactory("AttackBuilding");
  const attack = await elevator.deploy();

  await attack.deployed();

  console.log("attack deployed to:", attack.address);

  await attack.attack();
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
