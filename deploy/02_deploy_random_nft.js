const { developmentChains, networkConfig } = require("../helper-hardhat-config");
const { network } = require("hardhat");
const {
  uploadFiles,
  storeTokenUriMetadata,
} = require("../utils/uploadToPinata");

const ImagesLocation = "./images/random";
const metadataTemplate = {
  id: "",
  name: "",
  description: "",
  image: "",
  attributes: [
    {
      trait_type: "Cute_ness",
      value: 100,
    },
  ],
};

const func = async ({ deployments, getNamedAccounts }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;
  
  let tokenUris;
  if (process.env.UPLOAD_PINATA == "true") {
    tokenUris = await handleTokenUris();
  }
  const mintFee = networkConfig[chainId].mintFee;
  const args = [tokenUris, mintFee, deployer];
  const RandomNft = await deploy("RandomNft", {
    args: args,
    from: deployer,
    log: true,
    waitwaitConfirmation: 5,
  });

  if (!developmentChains.includes(network.name)) {
    log("Verifying contract...");
    await run("verify:verify", {
      address: RandomNft.address,
      constructorArguments: args,
    });
  }
};

async function handleTokenUris() {
  const tokenUris = [];
  const { responses: imageUploadResponses, files } = await uploadFiles(
    ImagesLocation
  );
  for (imageUploadIndex in imageUploadResponses) {
    let tokenUriMetaData = { ...metadataTemplate };
    tokenUriMetaData.name = files[imageUploadIndex];
    tokenUriMetaData.id = imageUploadResponses[imageUploadIndex].ID;
    tokenUriMetaData.description = `An adorable ${tokenUriMetaData.name} pup!`;
    tokenUriMetaData.image = `ipfs://${imageUploadResponses[imageUploadIndex].IpfsHash}`;
    console.log(
      `Uploading data of ${imageUploadResponses[imageUploadIndex].Name}`
    );
    const metadatauploadresponse = await storeTokenUriMetadata(
      tokenUriMetaData
    );
    console.log("metadatauploadresponse : ", metadatauploadresponse);
    tokenUris.push(`ipfs://${metadatauploadresponse.IpfsHash}`);
  }
  console.log("TokenUris are : ", tokenUris);
  return tokenUris;
}

module.exports = func;
module.exports.tags = ["all", "RandomNft"];
