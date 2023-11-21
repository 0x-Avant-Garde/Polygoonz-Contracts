// scripts/deploy1155.js
const { ethers, upgrades } = require("hardhat");

async function main() {
  const GoonzPals = await ethers.getContractFactory("GoonzPals");
  const goonzPals = await upgrades.deployProxy(GoonzPals);
  await goonzPals.deployed();
  console.log("Pals deployed to:", goonzPals.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
