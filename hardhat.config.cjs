require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();
const {API_URL, PRIVATE_KEY} = process.env;
module.exports = {
    etherscan: {
        apiKey: "ABCDE12345ABCDE12345ABCDE123456789",
    },
    solidity: "0.8.19",
    defaultNetwork: "sepolia",
    networks: {
        hardhat: {},
        sepolia: {
            url: API_URL,
            accounts: [`0x${PRIVATE_KEY}`]
        }
    },
}
