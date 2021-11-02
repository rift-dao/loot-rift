const { contract } = require('@openzeppelin/test-environment');

const Crystals = contract.fromArtifact('Crystals');
const Mana = contract.fromArtifact('Mana');

(async () => {
    let output = [];
    const manaInstance = await Mana.new();

    output.push('----------');
    const estimatedGas = await Crystals.new.estimateGas();
    output.push(`⛽ Estimations`);

    output.push(`\t${estimatedGas}\t-\tDeployment`);
    const crystalsInstance = await Crystals.new();

    

    const estimatedInit = await crystalsInstance.ownerInit.estimateGas(
        manaInstance.address,
        '0x0000000000000000000000000000000000000000',
        '0x0000000000000000000000000000000000000000'
    );
    await crystalsInstance.ownerInit(
        manaInstance.address,
        '0x0000000000000000000000000000000000000000',
        '0x0000000000000000000000000000000000000000'
    );

    // TODO: Figure out how to test claim, claimWithLoot, ownerClaim
    // const functionsToEstimate = [];
    const functionsToEstimate = ['tokenURI', 'getName', 'getLevel', 'getResonance', 'getSpin'];
    const functionEstimateMap = { deploy: estimatedGas, init: estimatedInit };

    // const fnEstimatedGas = await crystalsInstance.tokenURI.estimateGas(1);
    // output.push(`\t${fnEstimatedGas}\t-\ttokenURI`);

    for (let i = 0; i < functionsToEstimate.length; i++) {
        const fnName = functionsToEstimate[i];
        
        const fnEstimatedGas = await crystalsInstance[fnName].estimateGas(1);

        functionEstimateMap[fnName] = fnEstimatedGas;
        output.push(`\t${fnEstimatedGas}\t-\t${fnName}`);
    }
    
    output.push('----------\n');
    
    // add JSON output as first line
    output = [ JSON.stringify(functionEstimateMap), '', ...output];
    console.log(output.join('\n'));
    process.exit();
})();
