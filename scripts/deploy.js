const { ethers } = require("hardhat");

async function main() {
  // 部署 TokenA
  const Token = await ethers.getContractFactory("Token");
  const tokenA = await Token.deploy("TokenA", "TKA", ethers.parseEther("1000000"));
  await tokenA.waitForDeployment();
  console.log("TokenA deployed to:", await tokenA.getAddress());

  // 部署 TokenB
  const tokenB = await Token.deploy("TokenB", "TKB", ethers.parseEther("1000000"));
  await tokenB.waitForDeployment();
  console.log("TokenB deployed to:", await tokenB.getAddress());

  // 部署 Pair
  const UniswapPair = await ethers.getContractFactory("UniswapPair");
  const pair = await UniswapPair.deploy(await tokenA.getAddress(), await tokenB.getAddress());
  await pair.waitForDeployment();
  console.log("Pair deployed to:", await pair.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
