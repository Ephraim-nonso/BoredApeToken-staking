import { Signer } from "ethers";
import { ethers } from "hardhat";

const stakingAddress = "0xbe13cdad7df8bd3c7f481b78ddb09314313c33e3";
const BoredAPEcontract = "0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D";
const BRTContract = "0x5c16027BeAA623a275009022fDf325a7DB078664";

async function Staking() {
  // Deploy the stake contract.
  const Staking = await ethers.getContractFactory("StakingContract");
  const stake = await Staking.deploy();
  await stake.deployed();

  //@ts-ignore
  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [stakingAddress],
  });

  //@ts-ignore
  await hre.network.provider.send("hardhat_setBalance", [
    stakingAddress,
    "0x10000000000000000000000000",
  ]);

  // Get the signer to excecute the transfer.
  const signer = await ethers.getSigner(stakingAddress);

  // Check that the staker owns a BRT token.
  const checkToken = await ethers.getContractAt("BRT", BRTContract, signer);
  const balToken = await checkToken.balanceOf(stakingAddress);
  console.log(balToken);

  // Check the number of tokenId that a BoredApe NFT address owns.
  const BoredApeNFTToken = await ethers.getContractAt(
    "IERC721",
    BoredAPEcontract
  );
  const balNFT = await BoredApeNFTToken.balanceOf(stakingAddress);
  console.log(balNFT);

  const done = await stake.connect(signer).stake(5);
  console.log(done);

  // Check amount of token of the staker after staking.
  const balTokenAfter = await checkToken.balanceOf(stakingAddress);
  console.log(balTokenAfter);
}

Staking().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
