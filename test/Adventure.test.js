// const { accounts, contract } = require('@openzeppelin/test-environment');
const { BN } = require('@openzeppelin/test-helpers');
const truffleAssert = require('truffle-assertions');
const { expect } = require('chai');
const Mana = artifacts.require('Mana');
const Crystals = artifacts.require('Crystals');
const Loot = artifacts.require('NotLoot');
const Rift = artifacts.require('Rift');
const EnterRift = artifacts.require('EnterTheRift');
const RiftQuests = artifacts.require('RiftQuests');
const Calculator = artifacts.require('CrystalManaCalculator');
const CrystalsMetadata = artifacts.require('CrystalsMetadata');

contract('Adventure', function ([owner, other]) {

    beforeEach(async function () {
        this.mana = await Mana.new({ from: owner });
        this.crystals = await Crystals.new(this.mana.address, { from : owner });
        this.loot = await Loot.new({ from: owner });
        this.rift = await Rift.new({ from: owner });
        this.quests = await RiftQuests.new(this.rift.address, { from: owner });
        this.enterRift = await EnterRift.new(this.quests.address, this.crystals.address, this.mana.address, { from: owner });
        this.calculator = await Calculator.new(this.crystals.address, { from: owner });
        this.metadata = await CrystalsMetadata.new(this.crystals.address, { from: owner });

        await this.mana.addController(this.crystals.address);
        await this.mana.addController(this.rift.address);
        await this.crystals.ownerSetMetadataAddress(this.metadata.address);
        await this.crystals.ownerSetCalculatorAddress(this.calculator.address);
        await this.crystals.ownerSetRiftAddress(this.rift.address);
        await this.crystals.ownerSetLootAddress(this.loot.address);
        await this.crystals.ownerSetMLootAddress(this.loot.address);
        await this.rift.addRiftObject(this.crystals.address);
        await this.rift.ownerSetLootAddress(this.loot.address);
        await this.rift.ownerSetRiftQuestsAddress(this.quests.address);
        await this.quests.addQuest(this.enterRift.address);

        await this.rift.ownerSetXpRequirement(1, 100);
        await this.rift.ownerSetLevelChargeAward(1, 1);
        await this.loot.mint(1);
    });

    it('has a deploying balance', async function () {
        const balance = await this.mana.balanceOf(owner);
        assert.equal(balance.valueOf(), 1000000);
    });

    it ('has loot', async function () {
        // non owner can not transfer
        await truffleAssert.fails(this.loot.transferFrom(other, owner, 1));
        //but transferring in general works
        await truffleAssert.passes(
            this.loot.transferFrom(owner, other, 1, { from: owner }),
        );
    });

    it ('can perform a quest step', async function () {
        // can't be done w/o loot
        await truffleAssert.fails(this.quests.completeStep(this.enterRift.address, 1, 1));

        await this.loot.mint(1);
        
        await truffleAssert.passes(this.quests.completeStep(this.enterRift.address, 1, 1));
    });

    it ('has 50 xp after first quest step', async function () {
        assert.equal((await this.rift.getBag(1)).xp, 0, "New bags have no XP");

        // performs quest step
        await truffleAssert.passes(this.quests.completeStep(this.enterRift.address, 1, 1));

        assert.equal((await this.rift.getBag(1)).xp, 50, "First quest step gives 50");
    });

    it ('can not perform the same step twice', async function () {
        await truffleAssert.passes(this.quests.completeStep(this.enterRift.address, 1, 1));
        await truffleAssert.fails(this.quests.completeStep(this.enterRift.address, 1, 1));
    });

    it ('can create a crystal', async function () {
        await truffleAssert.fails(this.crystals.mintCrystal(1, { value: web3.utils.toWei("0", "ether") }));

        // // do first step for a rift charge
        await this.quests.completeStep(this.enterRift.address, 1, 1)
        assert.equal((await this.rift.getBag(1)).charges, 1, "Should have 1 charge");

        // // use charge
        await truffleAssert.passes(this.crystals.mintCrystal(1, { value: web3.utils.toWei("0.02", "ether") }));
        assert.equal((await this.rift.getBag(1)).charges, 0, "Should have 0 charges");
    });

});
