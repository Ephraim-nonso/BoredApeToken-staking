import { Signer } from "ethers";
import { ethers } from "hardhat";

// Addresses for the contract testing.
const deployerAddress = "0xf18be8A5FcBD320fDe04843954c1c1A155b9Ae2b";
const BoredNFT = "0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D";

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
  console.log(await (await erc).transfer(BoredNFT, 400000));
  console.log(await (await erc).address);

  const bal = await (await erc).balanceOf(BoredNFT);
  console.log(bal);
}

ERC().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
