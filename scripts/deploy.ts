import { ethers } from "hardhat";

async function main() {
  const owners = [
    "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
    "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
    "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC",
  ];

  const minConfrimations = 2;

  const MultiSig = await ethers.getContractFactory("MultiSig");
  const multiSig = await MultiSig.deploy(owners, minConfrimations);

  await multiSig.deployed();

  console.log(`MultiSig deployed to ${multiSig.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
