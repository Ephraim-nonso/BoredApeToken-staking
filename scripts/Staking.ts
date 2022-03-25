import { ethers } from "hardhat";

// The Token Deployer and contract Address.
const TOKENCONTRACT = "0x7f9a1fF287fD5F1319C098eb79ecb8c9c446f322";
const deployerAddress = "0xf18be8A5FcBD320fDe04843954c1c1A155b9Ae2b";

// Ape Contract.
const APECONTRACT = "0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D";
const BOREDAPEHOLDER = "0xbe13cdad7df8bd3c7f481b78ddb09314313c33e3";

// The Staking Address.
const STAKINGCONTRACT = "0x9472B9A4FeE3206a817767afB1A0D6Bdd66A910a";

async function prank(address: string) {
  //@ts-ignore
  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [address],
  });
}

async function setBal(address: string) {
  //@ts-ignore
  await hre.network.provider.send("hardhat_setBalance", [
    address,
    "0x100023197410500275142",
  ]);
}

async function Staking() {
  // Get The Staking Contract
  const GetStaking = await ethers.getContractAt(
    "StakingContract",
    STAKINGCONTRACT
  );

  // Get Token Contract.
  const GetToken = await ethers.getContractAt("IERC20", TOKENCONTRACT);

  await prank(BOREDAPEHOLDER);
  const signer = await ethers.getSigner(BOREDAPEHOLDER);

  // Approve contract the token.
  await GetToken.connect(signer).approve(STAKINGCONTRACT, "100000");

  console.log(await GetToken.allowance(BOREDAPEHOLDER, STAKINGCONTRACT));
  // Stake
  // await GetStaking.connect(signer).stake("100000");

  console.log(await GetStaking.connect(signer).getContractBalance());
}

Staking().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
