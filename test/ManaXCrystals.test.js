const { accounts, contract } = require('@openzeppelin/test-environment');
const { BN, expectRevert, time } = require('@openzeppelin/test-helpers');
const { expect, assert } = require('chai');

const Crystals = contract.fromArtifact('Crystals');
const Mana = contract.fromArtifact('Mana');

let manaInstance = null;
let crystalsInstance = null;
// TODO: this should match _MAX in Crystals.sol
const _MAX = 1000000;

describe('Mana X Crystals Pre-Claim', () => {
  before(async () => {
      manaInstance = await Mana.new();
      crystalsInstance = await Crystals.new(manaInstance.address);
      await manaInstance.ownerSetCContractAddress(crystalsInstance.address);
  });
  
  after(() => {
      manaInstance = null;
      crystalsInstance = null;
  });

  it('should be claimed', async () => {
    await crystalsInstance.claim(8999, { from: accounts[0] });
    const token = await crystalsInstance.tokenOfOwnerByIndex(accounts[0], 0);
    expect(token).to.be.bignumber.equal('8999')
  });

  it('should generate mana on claim', async () => {
    await crystalsInstance.claim(8998, { from: accounts[1] });

    const manaBalance = await manaInstance.balanceOf(accounts[1]);
    expect(manaBalance).to.be.bignumber.equal('1');
  });
});

describe('Mana X Crystals With Claimed', () => {
  // NOTE: some tests use time.increase which increases the blockchain time for all tests in this block
  // make sure your tests compensate to match...
  before(async () => {
      manaInstance = await Mana.new();
      crystalsInstance = await Crystals.new(manaInstance.address);
      await manaInstance.ownerSetCContractAddress(crystalsInstance.address);
      await crystalsInstance.claim(8999, { from: accounts[0] });
      await crystalsInstance.claim(8998, { from: accounts[1] });
      await crystalsInstance.claim(8997, { from: accounts[2] });

      await manaInstance.mint(100, { from: accounts[0] });
  });
  
  after(() => {
      manaInstance = null;
      crystalsInstance = null;
  });

  it('should generate mana on charge', async () => {
    const manaBefore = (await manaInstance.balanceOf(accounts[0])).toNumber();
    await crystalsInstance.chargeCrystal(8999, { from: accounts[0] });
    const manaAfter = await manaInstance.balanceOf(accounts[0]);
    const resonance = (await crystalsInstance.getResonance(8999)).toNumber();

    expect(manaAfter).to.be.bignumber.equal(resonance + manaBefore + '');
  });

  it('should not be chargeable twice', async () => {
    await crystalsInstance.chargeCrystal(8998, { from: accounts[1] });
    
    const dayInSeconds = 24 * 60 * 60;
    // add ~23 hours to the blockchain
    await time.increase(dayInSeconds - (60 * 60));

    await expectRevert(
      crystalsInstance.chargeCrystal(8998, { from: accounts[1] }),
      "You must wait before you can charge this Crystal again"
    );
  });

  it('should be chargeable after a day', async () => {
    const manaBefore = (await manaInstance.balanceOf(accounts[2])).toNumber();
    await crystalsInstance.chargeCrystal(8997, { from: accounts[2] });
    
    // add ~25 hours to the blockchain
    time.increase(25 * 60 * 60);

    await crystalsInstance.chargeCrystal(8997, { from: accounts[2] });
    const manaAfter = await manaInstance.balanceOf(accounts[2]);

    const resonance = (await crystalsInstance.getResonance(8997)).toNumber();
    expect(manaAfter).to.be.bignumber.equal((resonance * 2) + manaBefore + '');
  });

  it('should not be levelable', async () => {
    await crystalsInstance.claim(8996, { from: accounts[0] });
    // const dayInSeconds = 24 * 60 * 60;
    // // add ~23hours to the blockchain
    // time.increase(dayInSeconds - (60 * 60));
    const balance = (await manaInstance.balanceOf(accounts[0])).toNumber();

    await expectRevert(
      crystalsInstance.levelUpCrystal(8996, { from: accounts[0] }),
      "This crystal is not ready to be leveled up"
    );
  });

  it('should be levelable after 1 day', async () => {
    await crystalsInstance.claim(8995, { from: accounts[0] });

    const spin = (await crystalsInstance.getSpin(8995)).toNumber();
    const resonance = (await crystalsInstance.getResonance(8995)).toNumber();
    const daysRequired = Math.ceil(spin / resonance);

    // add till almost full charge
    time.increase(((24 * daysRequired) - 1) * 60 * 60);

    await expectRevert(
      crystalsInstance.levelUpCrystal(8995, { from: accounts[0] }),
      "This crystal is not ready to be leveled up"
    );
    
    // finish charging
    time.increase(2 * 60 * 60);

    const manaBefore = (await manaInstance.balanceOf(accounts[0])).toNumber();
    console.log('manaBefore', manaBefore);
    console.log('crystalsInstance.getSpin(8995)', (await crystalsInstance.getSpin(8995)).toNumber());
    await crystalsInstance.levelUpCrystal(8995, { from: accounts[0] });
    const manaAfter = await manaInstance.balanceOf(accounts[0]);

    expect(manaAfter).to.be.bignumber.equal(1 + manaBefore - Math.floor(spin / 2) + '');
    const token = await crystalsInstance.tokenOfOwnerByIndex(accounts[0], 2);
    expect(token).to.be.bignumber.equal(8995 + _MAX + '');
  });
});
