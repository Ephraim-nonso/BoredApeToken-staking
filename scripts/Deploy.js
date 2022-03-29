const { ethers } = require("hardhat");
const {
  DefenderRelayProvider,
  DefenderRelaySigner,
} = require("defender-relay-client/lib/ethers");

async function main() {
  // Relayer
  const credentials = {
    apiKey: process.env.API_KEY,
    apiSecret: process.env.API_SECRET,
  };
  const provider = new DefenderRelayProvider(credentials);
  const signer = new DefenderRelaySigner(credentials, provider, {
    speed: "fast",
  });

  const ERC20Token = await ethers.getContractFactory("BRT");
  const ercToken = await ERC20Token.connect(signer).deploy(
    "Bored Ape Token",
    "BRT"
  );

  await ercToken.deployed();
  console.log();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
