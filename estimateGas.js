const { contract } = require('@openzeppelin/test-environment');
const { BN } = require('@openzeppelin/test-helpers');

const Rift = contract.fromArtifact('Rift');

(async () => {
    let output = [];

    output.push('----------');
    const estimatedGas = await Rift.new.estimateGas();
    output.push(`⛽ Estimations`);

    output.push(`\t${estimatedGas}\t-\tDeployment`);
    const riftInstance = await Rift.new();

    // TODO: Figure out how to test claim, claimWithLoot, ownerClaim
    const functionsToEstimate = ['tokenURI'];
    const functionEstimateMap = { deploy: estimatedGas };

    for (let i = 0; i < functionsToEstimate.length; i++) {
        const fnName = functionsToEstimate[i];
        
        const fnEstimatedGas = await riftInstance[fnName].estimateGas();

        functionEstimateMap[fnName] = fnEstimatedGas;
        output.push(`\t${fnEstimatedGas}\t-\t${fnName}`);
        console.log('fnName', fnName);
    }
    
    output.push('----------\n');
    
    // add JSON output as first line
    output = [ JSON.stringify(functionEstimateMap), '', ...output];
    console.log(output.join('\n'));
    process.exit();
})();
