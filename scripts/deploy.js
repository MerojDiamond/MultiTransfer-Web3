import hre from "hardhat";
import fs from "fs";
import path from "path";

const ethers = hre.ethers

async function main() {
    const [deployer] = await ethers.getSigners()
    const currentTimestampInSeconds = Math.round(Date.now() / 1000);
    const unlockTime = currentTimestampInSeconds + 60;
    // const transfer = await ethers.deployContract("MultiTransfer")
    // await transfer.waitForDeployment()
    console.log(unlockTime)
    const token = await ethers.deployContract("SimpleToken")
    await token.waitForDeployment()
    console.log(token)
    saveFrontendFiles({
        // MultiTransfer: transfer,
        SimpleToken: token
    })
}

function saveFrontendFiles(contracts) {
    const contractsDir = path.join("./", "contracts")
    Object.entries(contracts).forEach((i) => {
        const [name, contract] = i
        if (contract) {
            fs.writeFileSync(
                path.join(contractsDir, '/', name + '-address.json'),
                JSON.stringify({[name]: contract.target}, undefined, 2)
            )
        }
        const ContractArtifact = hre.artifacts.readArtifactSync(name)
        fs.writeFileSync(
            path.join(contractsDir, '/', name + '.json'),
            JSON.stringify(ContractArtifact, null, 2)
        )
    })
}

main()
    .then(() => process.exit(0)).catch((e) => {
    console.error(e)
    process.exit(1)
})