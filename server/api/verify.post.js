import axios from "axios";
import fs from "fs";
import { ethers } from "ethers";

const sourceCode = fs.readFileSync("./contracts/Tokens.sol", "utf8");

export default defineEventHandler(async (event) => {
  let data = await readBody(event);
  const abi = [
    "constructor(string name, string symbol, uint8 decimals, uint256 totalSupply)",
  ];
  const iface = new ethers.Interface(abi);
  const name = data.name;
  const symbol = data.symbol;
  const decimals = data.decimals;
  const totalSupply = ethers.parseUnits(data.totalSupply.toString(), decimals);
  const constructorArgs = iface.encodeDeploy([
    name,
    symbol,
    decimals,
    totalSupply,
  ]);
  return constructorArgs;
  try {
    const response = await axios.post(
      "https://api.etherscan.io/api",
      {
        apikey: "X22E7IKIKMKYATXD7U7EYDP14HC6UN34CD",
        module: "contract",
        action: "verifysourcecode",
        chainId: 11155111,
        constructorArguments: constructorArgs,
        contractaddress: data.address,
        codeformat: "solidity-single-file",
        sourceCode: sourceCode,
        contractname: "SimpleToken",
        compilerversion: "v0.8.19+commit.7dd6d404",
        optimizationUsed: 0, // 1 for optimization enabled, 0 for disabled
        runs: 200, // number of runs
      },
      {
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      }
    );

    console.log("Etherscan API response:", response.data);
    return response.data; // Return data as needed
  } catch (error) {
    console.error("Error verifying contract:", error.message);
    throw error; // Throw error to handle it elsewhere if needed
  }
});
