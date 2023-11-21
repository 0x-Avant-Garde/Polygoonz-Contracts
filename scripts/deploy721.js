// scripts/deploy721.js
const { ethers, upgrades } = require("hardhat");

async function main() {
  const GoonzBases = await ethers.getContractFactory("GoonzBases");
  const goonzBases = await upgrades.deployProxy(GoonzBases);
  await goonzBases.deployed();
  console.log("Bases deployed to:", goonzBases.address);
}

main();
