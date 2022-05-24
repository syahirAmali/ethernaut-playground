
const hre = require("hardhat");

async function main() {

  const CoinFlip = await hre.ethers.getContractFactory("CoinFlipAttack");
  // const attack = await CoinFlip.deploy("0xc6B02E1b322203e37940c2f612Eb218087395eec");
  const attack = await CoinFlip.attach("0x329BB3818623f50E964D9F806e5C5358b7D8EAd5");

  await attack.deployed();

  console.log("Greeter deployed to:", attack.address);

  await attack.attack();

  const CoinFlips = await hre.ethers.getContractFactory("CoinFlip");
  const flips = await CoinFlips.attach("0xc6B02E1b322203e37940c2f612Eb218087395eec");

  const win = await flips.consecutiveWins()
  console.log("wins", win);
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
