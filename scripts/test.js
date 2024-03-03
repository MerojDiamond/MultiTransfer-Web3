import hre from "hardhat"
let ethers = hre.ethers
async function main(){
    let [ac1, ac2,ac3] = await ethers.getSigners()
    const transfer = await ethers.deployContract("MultiTransfer")
    await transfer.waitForDeployment()
    console.log(transfer.target)
    let a =await transfer.test({
        value: ethers.parseEther('1')
    })
    console.log(a)
    a = await transfer.multiTransfersEthEqualAmount([ac1,ac2,ac3],20,{
        value: ethers.parseEther('70')
    })
    console.log(a)
}
main()