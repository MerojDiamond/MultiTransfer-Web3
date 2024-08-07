require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();
const {vars} = require("hardhat/config");
const ETHERSCAN_API_KEY = vars.get("ETHERSCAN_API_KEY");
const {API_URL, PRIVATE_KEY} = process.env;
module.exports = {
    sourcify: {
        enabled: true
    },
    etherscan: {
        apiKey: ETHERSCAN_API_KEY,
    },
    solidity: "0.8.20",
    defaultNetwork: "sepolia",
    networks: {
        hardhat: {},
        sepolia: {
            url: API_URL,
            accounts: [`0x${PRIVATE_KEY}`]
        }
    },
}
