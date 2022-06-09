
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
  let [user] = await ethers.getSigners();
  const recovery = await hre.ethers.getContractFactory("SimpleToken");
  const reco = await recovery.attach("0x3a4d40fcbAFE151c830BCbe3F3CAE930946b0278");

  console.log("reco deployed to:", reco.address);

  const recs = await reco.destroy(user.address)

}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
