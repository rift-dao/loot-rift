const { accounts, contract } = require('@openzeppelin/test-environment');
const { BN } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

const Crystals = contract.fromArtifact('Crystals'); // Loads a compiled contract

let crystalInstance = null;

before(async () => {
    crystalInstance = await Crystals.new();
});

const MOCK_0001 = {
    id: 1,
    name: 'Polished Brown Crystal of Detection',
    maxCapacity: '5',
    bonusMana: '4',
};

describe('Crystal getters', () => {
    it('should have valid tokenURI', async () => {
        const output = await crystalInstance.tokenURI(1);

        expect(output).to.contain('data:application/json;base64');
    });

    it('should have a valid image from tokenURI', async () => {
        const output = await crystalInstance.tokenURI(1);
        const jsonEncoded = output.substring(29);
        const json = Buffer.from(jsonEncoded, 'base64').toString();

        const { image } = JSON.parse(json);

        expect(image).to.contain('data:image/svg+xml;base64');
    });

    it('should getLevel', async () => {
        // TODO: this should match _MAX in Crystals.sol
        const _MAX = 1000000;
        const level1 = await crystalInstance.getLevel(1);
        expect(level1).to.be.bignumber.equal('1');
        
        const level2 = await crystalInstance.getLevel(_MAX + 1);
        expect(level2).to.be.bignumber.equal('2');
        
        const level9001 = await crystalInstance.getLevel((_MAX * 9000) + 1);
        expect(level9001).to.be.bignumber.equal('9001');

        const levelMax = await crystalInstance.getLevel(_MAX);
        expect(levelMax).to.be.bignumber.equal('1');


        // TODO: uint256 max value
    });

    it('should getMaxCapacity', async () => {
        const maxCapacity = await crystalInstance.getMaxCapacity(MOCK_0001.id);
        expect(maxCapacity).to.be.bignumber.equal(MOCK_0001.maxCapacity);
    });

    it('should getBonusMana', async () => {
        const bonusMana = await crystalInstance.getBonusMana(MOCK_0001.id);
        expect(bonusMana).to.be.bignumber.equal(MOCK_0001.bonusMana);
    });

    it('should getName', async () => {
        const name = await crystalInstance.getName(MOCK_0001.id);
        expect(name).to.be.equal(MOCK_0001.name);
    });

    // it('should have rare name', async () => {
    //     const colors = [];

    //     const start = 41;
    //     const range = 50;
    //     for(let i = start; i <= range; i++) {
    //         const color = await crystalInstance.getColor(i);
    //         colors.push(`#${i}: ${color}`);
    //     }

    //     expect('color').to.be.equal(colors.join('\n'));
    // });
});

describe('Crystal buisness', () => {
    before(async () => {
        const ownedCrystal = await crystalInstance.claim(8003);
        expect(true).to.be.true;
    });

    it('should chargeCrystal', async () => {
        const output = await crystalInstance.chargeCrystal.call(8003);
        console.log('output', output);
        expect(true).to.be.true;
    });
});
