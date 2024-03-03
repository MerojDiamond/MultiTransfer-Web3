import hre from "hardhat";

const ethers = hre.ethers
export default defineEventHandler(async (event) => {
    let data = await readBody(event)
    const currentTimestampInSeconds = Math.round(Date.now() / 1000);
    const unlockTime = currentTimestampInSeconds + 60;
    const token = await ethers.deployContract("SimpleToken", [unlockTime], {
        name: data.name, symbol: data.symbol, decimals: data.decimals, totalSupply: data.totalSupply
    })
    await token.waitForDeployment()
    return data
})