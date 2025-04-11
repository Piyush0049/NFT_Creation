const { PinataSDK } = require("pinata")
const fs = require("fs")
const { Blob } = require("buffer")
const path = require("path")
require("dotenv").config()

const pinata = new PinataSDK({
  pinataJwt: process.env.PINATA_JWT,
  pinataGateway: process.env.GATEWAY_URL
})

async function uploadFolder(filepath){
  try {
    const files = fs.readdirSync("./images/random");
    const folderPath = path.resolve(filepath);
    const blob = new Blob([fs.readdirSync("./images/random")]);
    const file = new File([blob], "images", { type: "text/plain"})
    const upload = await pinata.upload.public.file(file);
    console.log("Uploading To IPFS...")
    let responses = [];
    for(fileindex in files){
        const readableimage = fs.createReadStream(`${folderPath}/${files[fileindex]}`);
        try {
            const response = await PinataSDK.pinFileToIpfs(readableimage);
            responses.push(response);
        } catch (error) {
            console.error(error)
        }
    }
    console.log(files)
    console.log(upload)
  } catch (error) {
    console.log(error)
  }
}

module.exports = {
    uploadFolder
}
