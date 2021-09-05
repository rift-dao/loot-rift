const { accounts, contract } = require('@openzeppelin/test-environment');
const { BN } = require('@openzeppelin/test-helpers');
const expectEvent = require('@openzeppelin/test-helpers/src/expectEvent');
const { expect } = require('chai');

const Crystals = contract.fromArtifact('Crystals');
const Mana = contract.fromArtifact('Mana');

let manaInstance = null;
let crystalsInstance = null;

before(async () => {
    manaInstance = await Mana.new();
    crystalsInstance = await Crystals.new(manaInstance.address);
    await manaInstance.ownerSetCContractAddress(crystalsInstance.address);
});

after(() => {
    manaInstance = null;
    crystalsInstance = null;
});

describe('Mana', () => {
    it('should have set mana to owner', async () => {
        const owner = await manaInstance.owner();
        const output = await manaInstance.balanceOf(owner);

        expect(output).to.be.bignumber.eq('20');
    });

    // testing some tests
    it('should be burnable', async () => {
        const owner = await manaInstance.owner();

        await manaInstance.burn(13);
        const output = await manaInstance.balanceOf(owner);

        expect(output).to.be.bignumber.eq('7');
    });

    it('should be note be mintable by owner', async () => {
        const owner = await manaInstance.owner();
        await manaInstance.ccMintTo(10, owner);
        const output = await manaInstance.balanceOf(owner);
    });
});
