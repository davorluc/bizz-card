import * as dotenv from "dotenv";
import { PinataSDK } from "pinata-web3";

const pinata = new PinataSDK({
  pinataJwt: import.meta.env.VITE_PINATA_JWT,
  pinataGateway: import.meta.env.VITE_PINATA_URL,
});

const uploadToIPFS = async (file: File): Promise<string> => {
  try {
    const uploadResponse = await pinata.upload.file(file);
    console.log("File uploaded successfully:", uploadResponse);

    return `https://gateway.pinata.cloud/ipfs/${uploadResponse.IpfsHash}`;
  } catch (error) {
    console.error("Error uploading file to IPFS:", error);
    throw new Error("Failed to upload to IPFS.");
  }
};

export default uploadToIPFS;
