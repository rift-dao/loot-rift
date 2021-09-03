const { accounts, contract } = require('@openzeppelin/test-environment');
const { BN } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

const Rift = contract.fromArtifact('Rift'); // Loads a compiled contract

let riftInstace = null;

before(async () => {
    riftInstance = await Rift.new();
});

describe('Rift', () => {
    it('should have valid tokenURI', async () => {
        const output = await riftInstance.tokenURI(1);

        expect(output).to.contain('data:application/json;base64');
    });

    it('should have a valid image from tokenURI', async () => {
        const output = await riftInstance.tokenURI(1);
        const jsonEncoded = output.substring(29);
        const json = Buffer.from(jsonEncoded, 'base64').toString();

        const { image } = JSON.parse(json);

        expect(image).to.contain('data:image/svg+xml;base64');
    });

    it('should getLevel', async () => {
        // TODO: this should match _MAX in Rift.sol
        const _MAX = 1000000;
        const level1 = await riftInstance.getLevel(1);
        expect(level1).to.be.bignumber.equal('1');
        
        const level2 = await riftInstance.getLevel(_MAX + 1);
        expect(level2).to.be.bignumber.equal('2');
        
        const level3 = await riftInstance.getLevel((_MAX * 2) + 1);
        expect(level3).to.be.bignumber.equal('3');
        
        const level1000 = await riftInstance.getLevel((_MAX * 999) + 1);
        expect(level1000).to.be.bignumber.equal('1000');
        
        const level9001 = await riftInstance.getLevel((_MAX * 9000) + 1);
        expect(level9001).to.be.bignumber.equal('9001');

        // TODO: uint256 max value
    });

    it('should getMaxCapacity', async () => {
        const maxCapacity = await riftInstance.getMaxCapacity(1);
        expect(maxCapacity).to.be.bignumber.equal('4');
    });

    it('should getBonusMana', async () => {
        const bonusMana = await riftInstance.getBonusMana(1);
        expect(bonusMana).to.be.bignumber.equal('2');
    });
});
