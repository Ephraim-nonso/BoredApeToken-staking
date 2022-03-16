import { Signer } from "ethers";
import { ethers } from "hardhat";

const stakingAddress = "0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D";

async function Staking() {
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

  const signer = await ethers.getSigner(stakingAddress);
  const done = await stake.connect(signer).stake(3200);
  console.log(done);
}

Staking().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
