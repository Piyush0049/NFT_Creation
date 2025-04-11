const { developmentChains } = require("../helper-hardhat-config");
const { network } = require("hardhat");
const { uploadFolder } = require("../utils/uploadToPinata");

const func = async ({ deployments, getNamedAccounts }) => {
//   const { deploy, log } = deployments;
//   const { deployer } = await getNamedAccounts();
//   const chainId = network.config.chainId;
//   const dogTokenUris = [];
//   const mintFee = developmentChains[chainId].mintFee;
//   const args = [dogTokenUris, mintFee, deployer];
//   if (process.env.UPLOAD_PINATA == "true") {
//     await handleTokenUris();
//   }

  await uploadFolder("./images/random");
//   const RandomNft = await deploy("RandomNft", {
//     args: args,
//     from: deployer,
//     log: true,
//     waitwaitConfirmation: 5,
//   });

//   if (!developmentChains.includes(network.name)) {
//     log("Verifying contract...");
//     await run("verify:verify", {
//       address: RandomNft.address,
//       constructorArguments: args,
//     });
//   }
};

async function handleTokenUris() {
  const tokenUris = [];
}

module.exports = func;
module.exports.tags = ["all", "RandomNft"];
