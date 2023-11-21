// scripts/deploy721.js
const { ethers, upgrades } = require("hardhat");

async function main() {
  const Tests = await ethers.getContractFactory("Tests");
  const tests = await upgrades.deployProxy(Tests);
  await tests.deployed();
  console.log("Bases deployed to:", tests.address);
}

main();
