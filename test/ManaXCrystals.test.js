const { accounts, contract } = require('@openzeppelin/test-environment');
const { BN } = require('@openzeppelin/test-helpers');

const { expect } = require('chai');

const Crystals = contract.fromArtifact('Crystals');
const Mana = contract.fromArtifact('Mana');

let manaInstance = null;
let crystalsInstance = null;

describe('Mana X Crystals Integration', () => {
  before(async () => {
      manaInstance = await Mana.new();
      crystalsInstance = await Crystals.new(manaInstance.address);
      await manaInstance.ownerSetCContractAddress(crystalsInstance.address);
  });
  
  after(() => {
      manaInstance = null;
      crystalsInstance = null;
  });

  it('should generate mana on claim', async () => {

    await crystalsInstance.claim(8999, { from: accounts[0] });
    const token = await crystalsInstance.tokenOfOwnerByIndex(accounts[0], 0);
    expect(token).to.be.bignumber.equal('8999');

    const manaBalance = await manaInstance.balanceOf(accounts[0]);
    expect(manaBalance).to.be.bignumber.equal('1');
  });

  it('should generate mana on charge', async () => {
    await crystalsInstance.claim(8998, { from: accounts[1] });
    const token = await crystalsInstance.tokenOfOwnerByIndex(accounts[1], 0);
    expect(token).to.be.bignumber.equal('8998');

    let manaBalance = await manaInstance.balanceOf(accounts[1]);
    expect(manaBalance).to.be.bignumber.equal('1');

    await crystalsInstance.chargeCrystal(8998, { from: accounts[1] });

    manaBalance = await manaInstance.balanceOf(accounts[1]);
    expect(manaBalance).to.be.bignumber.equal('6');

    await crystalsInstance.chargeCrystal(8998, { from: accounts[1] });

    manaBalance = await manaInstance.balanceOf(accounts[1]);
    expect(manaBalance).to.be.bignumber.equal('11');
  });
});
