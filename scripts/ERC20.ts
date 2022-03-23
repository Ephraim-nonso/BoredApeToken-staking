import { BigNumber, Signer } from "ethers";
import { ethers } from "hardhat";

// Addresses for the contract testing.
const deployerAddress = "0xf18be8A5FcBD320fDe04843954c1c1A155b9Ae2b";

// Ape ERC721 Contract
const ApeContract = "0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D";
const BoredNFTHolder = "0xbe13cdad7df8bd3c7f481b78ddb09314313c33e3";

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

async function ERC() {
  const signer = await ethers.getSigner(deployerAddress);
  await prank(deployerAddress);
  await setBal(deployerAddress);

  // Deployment of token to derive contract address.
  const ERC = await ethers.getContractFactory("BRT");
  const erc = ERC.connect(signer).deploy("Bored Ape Token", "BRT");
  await (await erc).deployed();
  console.log("The Token address:", (await erc).address);

  console.log(await (await erc).balanceOf(deployerAddress));

  // Check the number of Ape an holder possesses.
  const getBoredApe = await ethers.getContractAt("IERC721", ApeContract);

  console.log(await getBoredApe.balanceOf(BoredNFTHolder));
}

ERC().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// 0x1f312127D84fdcC5Cf224ed5A682aD9fD98ABF28
