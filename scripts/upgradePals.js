const { ethers, upgrades } = require("hardhat");

async function main() {
  const GoonzPalsV2 = await ethers.getContractFactory("GoonzPals");
  console.log("Upgrading GoonzBases...");
  await upgrades.upgradeProxy(
    "0x064B05df5cfe5686814d773bF1369251Cc3752be",
    GoonzPalsV2
  );
  console.log("GoonzPals upgraded");
}

main();
