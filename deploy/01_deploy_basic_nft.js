const { developmentChains } = require("../helper-hardhat-config");
const { network } = require("hardhat");

const func = async ({ deployments, getNamedAccounts }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const basicNft = await deploy("BasicNft", {
    from: deployer,
    args: [],
    log: true,
    waitConfirmation: 1,
  });
  if (!developmentChains.includes(network.name)) {
    log("Verifying contract...");
    await run("verify:verify", {
      address: basicNft.address,
      constructorArguments: [],
    });
  }
};

module.exports = func;
module.exports.tags = ["all", "BasicNft"];
