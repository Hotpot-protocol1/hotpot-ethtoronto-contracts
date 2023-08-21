const { networks } = require("../networks");
task("verify-contract", "Verifies contract")
  .addParam("contract", "Address of the client contract to verify")
  .setAction(async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error(
        'This command cannot be used on a local development chain.  Specify a valid network or simulate an Functions request locally with "npx hardhat functions-simulate".'
      );
    }
    const gateway = networks[network.name].AXELAR_GATEWAY;
    const gasService = networks[network.name].AXELAR_GAS_SERVICE;
    const wrappedNativeToken =
      networks[network.name].AXELAR_WRAPPED_NATIVE_TOKEN;
    const symbol = networks[network.name].WRAPPED_TOKEN_SYMBOL;
    const hotpotDeployment = "0x30b5db47421Fc8Db08d1d2a5CD2fC1437378f66b";
    console.log(`Verifying contract to ${taskArgs.contract}`);

    try {
      console.log("\nVerifying contract...");
      await run("verify:verify", {
        address: taskArgs.contract,
        constructorArguments: [
          gasService,
          gateway,
          hotpotDeployment,
          symbol,
          wrappedNativeToken,
        ],
      });
      console.log("Contract verified");
    } catch (error) {
      if (!error.message.includes("Already Verified")) {
        console.log(
          "Error verifying contract.  Delete the build folder and try again."
        );
        console.log(error);
      } else {
        console.log("Contract already verified");
      }
    }
  });
