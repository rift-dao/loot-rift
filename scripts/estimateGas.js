const { contract } = require('@openzeppelin/test-environment');

const Rift = contract.fromArtifact('Rift');

(async () => {
    let output = [];

    output.push('----------');
    const estimatedGas = await Rift.new.estimateGas();
    output.push(`⛽ Estimations`);

    output.push(`\t${estimatedGas}\t-\tDeployment`);
    const riftInstance = await Rift.new();

    // TODO: Figure out how to test claim, claimWithLoot, ownerClaim
    const functionsToEstimate = ['tokenURI', 'getLevel', 'getBonusMana', 'getMaxCapacity'];
    const functionEstimateMap = { deploy: estimatedGas };

    // const fnEstimatedGas = await riftInstance.tokenURI.estimateGas(1);
    // output.push(`\t${fnEstimatedGas}\t-\ttokenURI`);

    for (let i = 0; i < functionsToEstimate.length; i++) {
        const fnName = functionsToEstimate[i];
        
        const fnEstimatedGas = await riftInstance[fnName].estimateGas(1);

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
