// scripts/generateStandardJsonInput.js
const fs = require("fs");
const path = require("path");
const {task} = require("hardhat/config");
let main = async (taskArgs, hre) => {
    const contractPath = path.join(__dirname, "../contracts/Tokens.sol");
    const contractContent = fs.readFileSync(contractPath, "utf8");

    const input = {
        language: "Solidity",
        sources: {
            "Tokens.sol": {
                content: contractContent,
            },
        },
        settings: {
            optimizer: {
                enabled: true,
                runs: 200,
            },
            outputSelection: {
                "*": {
                    "*": [
                        "abi",
                        "evm.bytecode",
                        "evm.deployedBytecode",
                        "evm.methodIdentifiers",
                    ],
                },
            },
        },
    };

    const outputPath = path.join(__dirname, "../artifacts/input.json");
    fs.writeFileSync(outputPath, JSON.stringify(input, null, 2));

    console.log(`Standard JSON input written to ${outputPath}`);
}
main().then(() => process.exit(0))
    .catch((e) => {
        console.error(e);
        process.exit(1);
    });
