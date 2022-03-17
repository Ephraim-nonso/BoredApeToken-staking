import { Signer } from "ethers";
import { ethers } from "hardhat";

// Addresses for the contract testing.
const deployerAddress = "0xf18be8A5FcBD320fDe04843954c1c1A155b9Ae2b";
const BoredNFTHolder = "0xbe13cdad7df8bd3c7f481b78ddb09314313c33e3";

async function ERC() {
  const signer = await ethers.getSigner(deployerAddress);

  //@ts-ignore
  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [deployerAddress],
  });

  //@ts-ignore
  await hre.network.provider.send("hardhat_setBalance", [
    deployerAddress,
    "0x20000000000000000000000000",
  ]);

  // Deployment of token to derive contract address.
  const ERC = await ethers.getContractFactory("BRT");
  const erc = ERC.connect(signer).deploy(
    "Bored Ape Token",
    "BRT",
    10000000000000
  );
  await (await erc).deployed();
  console.log(await (await erc).balanceOf(deployerAddress));

  // Transfer the token to the BoredNFT.
  await (await erc).transfer(BoredNFTHolder, 400000);
  console.log(await (await erc).address);

  const bal = await (await erc).balanceOf(BoredNFTHolder);
  console.log(bal);
  console.log(await (await erc).balanceOf(deployerAddress));
}

ERC().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
