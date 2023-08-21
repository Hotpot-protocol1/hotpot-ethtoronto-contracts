const { networks } = require("../../networks");

task("deploy-hotpot", "Deploys Hotpot Implementation contract").setAction(
  async (taskArgs, hre) => {
    console.log(`Deploying Hotpot contract to ${network.name}`);

    if (network.name === "hardhat") {
      throw Error(
        'This command cannot be used on a local development chain.  Specify a valid network or simulate an Functions request locally with "npx hardhat functions-simulate".'
      );
    }
    const hotpot = await ethers.getContractFactory("Hotpot");
    const gateway = networks[network.name].AXELAR_GATEWAY;
    const eas = networks[network.name].EAS;
    const schemaId =
      "0x2c5ca635f20506a5963e5cb00b3b77f99f40b42bee9a705a0b68d57346030405";
    const hotpotContract = await hotpot.deploy(gateway, eas, schemaId, {
      gasPrice: 50000,
    });

    console.log(
      `\nWaiting 3 blocks for transaction ${hotpotContract.deployTransaction.hash} to be confirmed...`
    );

    await hotpotContract.deployTransaction.wait(
      networks[network.name].WAIT_BLOCK_CONFIRMATIONS
    );
    console.log(
      `Hotpot deployed to ${hotpotContract.address} on ${network.name}`
    );
    console.log("\nVerifying contract...");
    try {
      await run("verify:verify", {
        address: hotpotContract.address,
        constructorArguments: [gateway, eas, schemaId],
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
  }
);
