import { ethers } from "hardhat";

const deployerAddress = "0xf18be8A5FcBD320fDe04843954c1c1A155b9Ae2b";
const tokenAddress = "0x1f312127D84fdcC5Cf224ed5A682aD9fD98ABF28";

// Ape Contract.
const ApeContract = "0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D";

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
  const signer = await ethers.getSigner(deployerAddress);
  await prank(deployerAddress);
  await setBal(deployerAddress);

  const getToken = await ethers.getContractAt("IERC20", tokenAddress);
  console.log(await getToken.balanceOf(deployerAddress));

  //   const StakingContract = await ethers.getContractFactory("StakingContract");
  //   const stake = StakingContract.deploy(tokenAddress, ApeContract);

  //   await (await stake).deployed();

  //   console.log("Deployed stake contract is:", (await stake).address);

  //   const val = await (await stake).stake(5);
  //   console.log(val);
}

Staking().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
