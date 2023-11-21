// scripts/deploy1155.js
const { ethers, upgrades } = require("hardhat");

async function main() {
  const GoonzItems = await ethers.getContractFactory("GoonzItems");
  const goonzItems = await upgrades.deployProxy(GoonzItems);
  await goonzItems.deployed();
  console.log("Items deployed to:", goonzItems.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
