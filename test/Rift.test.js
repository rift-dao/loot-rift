const { accounts, contract } = require('@openzeppelin/test-environment');
const { expect } = require('chai');

const Rift = contract.fromArtifact('Rift'); // Loads a compiled contract

describe('Rift', () => {
    it('should load', async () => {
        const riftInstance = await Rift.new();
        const estimatedGas = await riftInstance.tokenURI.estimateGas();
    });

    it('should have valid tokenURI', async () => {
        const riftInstance = await Rift.new();
        const output = await riftInstance.tokenURI();

        expect(output).to.contain('data:application/json;base64');

        // uncomment if you want to see the metadata
        // console.log('output', output);
    });

    it('should have a valid image from tokenURI', async () => {
        const riftInstance = await Rift.new();
        const output = await riftInstance.tokenURI();
        const jsonEncoded = output.substring(29);
        const json = Buffer.from(jsonEncoded, 'base64').toString();

        console.log('json', json);
        const { image } = JSON.parse(json);

        expect(image).to.contain('data:image/svg+xml;base64');

        console.log('image', image);
    });
});
