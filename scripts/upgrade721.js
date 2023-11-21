const { ethers, upgrades } = require("hardhat");

async function main() {
  const GoonzBasesV2 = await ethers.getContractFactory("GoonzBases");
  console.log("Upgrading GoonzBases...");
  await upgrades.upgradeProxy(
    "0x0F1DF6043Cf247BAb7B1fA434cb6aCe8E8c9E739",
    GoonzBasesV2
  );
  console.log("GoonzBases upgraded");
}

main();
