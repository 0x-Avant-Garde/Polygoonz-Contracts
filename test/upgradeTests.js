const { ethers, upgrades } = require("hardhat");

async function main() {
  const TestsV2 = await ethers.getContractFactory("Tests");
  console.log("Upgrading GoonzBases...");
  await upgrades.upgradeProxy(
    "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0",
    TestsV2
  );
  //   const testsv2 = await TestsV2.attach(
  //     "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0"
  //   );
  //   await testsv2.pause(false);
  console.log("GoonzBases upgraded");
}

main();
