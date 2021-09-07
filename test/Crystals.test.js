const { accounts, contract } = require('@openzeppelin/test-environment');
const { BN } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

const Crystals = contract.fromArtifact('Crystals');
const Mana = contract.fromArtifact('Mana');

const MOCK_0001 = {
    id: 1,
    name: 'Polished Crystal of the Twins',
    spin: '6',
    resonance: '3',
};

let crystalInstance = null;
let manaInstance = null;

describe('Crystal getters', () => {

    before(async () => {
        manaInstance = await Mana.new();
        crystalInstance = await Crystals.new(manaInstance.address);
    });

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

    it('should getSlab', async () => {
        const slab = await crystalInstance.getSlab(MOCK_0001.id, 1);

        expect(slab).to.be.eq('&#9701;');
        expect(await crystalInstance.getSlab(1000001, 1)).to.be.eq('&#9698;');
        expect(await crystalInstance.getSlab(2000001, 1)).to.be.eq('&#9699;');
        expect(await crystalInstance.getSlab(3000001, 1)).to.be.eq('&#9700;');
        expect(await crystalInstance.getSlab(4000001, 1)).to.be.eq('&#9701;');

        const slab2 = await crystalInstance.getSlab(MOCK_0001.id, 2);

        expect(slab2).to.be.eq('&#9701;');
        expect(await crystalInstance.getSlab(1000001, 2)).to.be.eq('&#9698;');
        expect(await crystalInstance.getSlab(2000001, 2)).to.be.eq('&#9699;');
        expect(await crystalInstance.getSlab(3000001, 2)).to.be.eq('&#9700;');
        expect(await crystalInstance.getSlab(4000001, 2)).to.be.eq('&#9701;');

        const slab3 = await crystalInstance.getSlab(MOCK_0001.id, 3);

        expect(slab3).to.be.eq('&#9700;');
        expect(await crystalInstance.getSlab(1000001, 3)).to.be.eq('&#9701;');
        expect(await crystalInstance.getSlab(2000001, 3)).to.be.eq('&#9698;');
        expect(await crystalInstance.getSlab(3000001, 3)).to.be.eq('&#9699;');
        expect(await crystalInstance.getSlab(4000001, 3)).to.be.eq('&#9700;');
    });

    it('should getSpin', async () => {
        const spin = await crystalInstance.getSpin(MOCK_0001.id);
        expect(spin).to.be.bignumber.equal(MOCK_0001.spin);
    });

    it('should getResonance', async () => {
        const resonance = await crystalInstance.getResonance(MOCK_0001.id);
        expect(resonance).to.be.bignumber.equal(MOCK_0001.resonance);
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

// describe('Crystal business', () => {
//     before(async () => {
//         const ownedCrystal = await crystalInstance.claim(8003);
//         expect(true).to.be.true;
//     });

//     it('should chargeCrystal', async () => {
//         const output = await crystalInstance.chargeCrystal.call(8003);
//         // console.log('output', output);
//         expect(true).to.be.true;
//     });
// });
