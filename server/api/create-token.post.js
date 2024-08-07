import hre from "hardhat";

const ethers = hre.ethers;
export default defineEventHandler(async (event) => {
  let data = await readBody(event);
  let tokenFile = "SimpleToken";
  if (data.com) {
    if (data.fixed) {
      if (data.isDual) tokenFile = "TokenDualComStatic";
      else tokenFile = "TokenTax";
    } else {
      if (data.isDual) tokenFile = "TokenDualComDynamic";
      else tokenFile = "TokenComDynamic";
    }
  }
  const tokenContract = await ethers.getContractFactory(tokenFile);
  let token;
  if (data.com && data.fixed)
    if (data.isDual)
      token = await tokenContract
        .connect(data.addre)
        .deploy(
          data.name,
          data.symbol,
          data.decimals,
          data.totalSupply,
          data.commission,
          data.sellCom,
          data.address
        );
    else
      token = await tokenContract.connect(data.addre).deploy(
        data.name,
        data.symbol,
        data.decimals,
        data.totalSupply
        // data.commission
        // data.address
      );
  else
    token = await tokenContract
      .connect(data.addre)
      .deploy(data.name, data.symbol, data.decimals, data.totalSupply);
  await token.waitForDeployment();
  // if (data.com && data.fixed)
  //   if (data.isDual)
  //     await verify(await token.getAddress(), [
  // data.name,
  // data.symbol,
  // data.decimals,
  // data.totalSupply,
  // data.commission,
  // data.sellCom,
  // ]);
  // else
  await verify(await token.getAddress(), [
    data.name,
    data.symbol,
    data.decimals,
    data.totalSupply,
    // data.commission,
  ]);
  // else
  //   await verify(await token.getAddress(), [
  //     data.name,
  //     data.symbol,
  //     data.decimals,
  //     data.totalSupply,
  //   ]);
  return {
    address: await token.getAddress(),
    ...data,
  };
});
const verify = async (contractAddress, args) => {
  console.log("Verifying contract...");
  try {
    await hre.run("verify:verify", {
      address: contractAddress,
      constructorArguments: args,
    });
  } catch (e) {
    if (e.message.toLowerCase().includes("already verified")) {
      console.log("Already verified!");
    } else {
      console.log(e);
    }
  }
};
