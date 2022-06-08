
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
  let [user] = await ethers.getSigners();
  const Attack = await hre.ethers.getContractFactory("AttackGate2");
  const attack = await Attack.deploy("0x675e127e07D87344AdAb25E0b3275A76eF08fbd8");

  await attack.deployed();

  console.log("attack deployed to:", attack.address);

}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
