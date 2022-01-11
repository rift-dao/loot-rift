// const { accounts, contract } = require('@openzeppelin/test-environment');
const { BN } = require('@openzeppelin/test-helpers');
const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');
const truffleAssert = require('truffle-assertions');
const { expect } = require('chai');
const { assertion } = require('@openzeppelin/test-helpers/src/expectRevert');
// const { deploy } = require('@openzeppelin/truffle-upgrades/dist/utils');
const Mana = artifacts.require('Mana');
const Crystals = artifacts.require('Crystals');
const Loot = artifacts.require('NotLoot');
const Rift = artifacts.require('Rift');
// const EnterRift = artifacts.require('EnterTheRift');
// const RiftQuests = artifacts.require('RiftQuests');
const CrystalsMetadata = artifacts.require('CrystalsMetadata');
const RiftData = artifacts.require('RiftData');

contract('Adventure', function ([owner, other]) {

    beforeEach(async function () {
        this.mana = await Mana.new({ from: owner });
        this.riftData = await deployProxy(RiftData);
        this.crystals = await deployProxy(Crystals, [this.mana.address, this.riftData.address]);
        this.loot = await Loot.new({ from: owner });
        this.mloot = await Loot.new({ from: owner });
        this.gloot = await Loot.new({ from: owner });
        this.rift = await deployProxy(Rift, [this.loot.address, this.mloot.address, this.gloot.address]);
        // this.quests = await RiftQuests.new(this.rift.address, { from: owner });
        // this.enterRift = await EnterRift.new(this.quests.address, this.crystals.address, this.mana.address, { from: owner });
        this.metadata = await CrystalsMetadata.new(this.crystals.address, { from: owner });

        await this.riftData.addRiftController(this.rift.address);
        await this.riftData.addRiftController(this.crystals.address);
        await this.riftData.addXPController(this.rift.address);
        await this.riftData.addXPController(this.crystals.address);

        await this.mana.addMintController(this.crystals.address);
        await this.mana.addMintController(this.rift.address);
        await this.mana.addBurnController(this.crystals.address);
        await this.mana.addBurnController(this.rift.address);
        await this.mana.ownerSetRift(this.rift.address);
        await this.crystals.ownerSetMetadataAddress(this.metadata.address);
        await this.crystals.ownerSetRiftAddress(this.rift.address);
        // await this.crystals.ownerSetOpenSeaProxy(this.loot.address); // placeholder
        await this.rift.ownerSetRiftData(this.riftData.address);
        await this.rift.addRiftObject(this.crystals.address);
        await this.rift.ownerSetManaAddress(this.mana.address);
        await this.rift.addRiftQuest(this.crystals.address);
        await this.rift.addRiftQuest(this.rift.address);
        // await this.rift.addRiftQuest(this.quests.address);
        // await this.quests.addQuest(this.enterRift.address);

        // await this.quests.ownerSetXP(this.enterRift.address, 1, 2);
        // await this.quests.ownerSetXP(this.enterRift.address, 2, 2);
        // await this.quests.ownerSetXP(this.enterRift.address, 3, 2);


        await this.rift.ownerSetLevelChargeAward(1, 1);
        await this.rift.ownerSetLevelChargeAward(2, 2);
        await this.rift.ownerSetLevelChargeAward(3, 2);
        await this.rift.ownerSetLevelChargeAward(4, 1);
        await this.rift.ownerSetLevelChargeAward(5, 2);
        await this.rift.ownerSetLevelChargeAward(6, 1);
        await this.rift.ownerSetLevelChargeAward(7, 1);
        await this.rift.ownerSetLevelChargeAward(8, 2);
        await this.rift.ownerSetLevelChargeAward(9, 1);
        await this.rift.ownerSetLevelChargeAward(10, 3);

        await this.loot.mint(1);
    });

    // it ('can burn a static object', async function () {
    //     console.log(await this.gloot.mint.estimateGas(2));
    //     await this.gloot.mint(2);
    //     await this.rift.addStaticBurnable( this.gloot.address, 100, 100, 100);
    //     await this.gloot.setApprovalForAll(this.rift.address, true);
    //     await truffleAssert.passes(this.rift.growTheRiftStatic(this.gloot.address, 2, 1, { from: owner }));
    // });

    it('should have default values for fresh bag', async function () {
        assert.equal((await this.riftData.getLevel(1)), 1, "New bags are level 1");
        assert.equal((await this.rift.getCharges(1)), 1, "New bags have 1 charge");

    });

    // it ('can reward XP and level up for activity', async function () {
    //     await this.riftData.addXPController(owner);
    //     // console.log(await this.rift.awardXP.estimateGas(1, 50));
    //     await this.riftData.addXP(100, 1);
    //     assert.equal((await this.riftData.getLevel(1)), 2, "100XP will level up");
    // });

    it('can consume charges', async function () {
        await this.rift.addRiftObject(owner);
        assert.equal((await this.rift.getCharges(1)), 1, "New bags have 1 charge");
        await this.rift.useCharge(1, 1, owner);
        assert.equal((await this.rift.getCharges(1)), 0, "Used a charge");
    });

    it ('gas tests', async function () {
        
        assert.equal((await this.riftData.getLevel(1)), 1, "New bags are level 1");

        await truffleAssert.passes(this.crystals.firstMint(1, { value: web3.utils.toWei("0.04", "ether") }))
        assert.equal((await this.riftData.xpMap(1)), 50, "First mint should add 50 XP");
        assert.equal((await this.riftData.getLevel(1)), 1, "Should be level 1");

        await truffleAssert.fails(this.crystals.firstMint(1, { value: web3.utils.toWei("0.04", "ether") }))

        await truffleAssert.fails(this.rift.growTheRift(this.crystals.address, 1, 1, { from: other }));

        await truffleAssert.passes(this.rift.growTheRift(this.crystals.address, 1, 1, { from: owner }));
        assert.equal((await this.riftData.getLevel(1)), 2, "Should be level 2");


        console.log(await this.crystals.mintCrystal.estimateGas(1, { from: owner }));
        await truffleAssert.passes(this.crystals.mintCrystal(1, { from: owner }));
        assert.equal((await this.riftData.getLevel(1)), 2, "Should be level 2");
        console.log(await this.crystals.mintCrystal.estimateGas(1, { from: owner }));
        console.log(await this.rift.getCharges(1));
        await truffleAssert.passes(this.crystals.mintCrystal(1, { from: owner }));
        console.log(await this.rift.getCharges(1));

        await truffleAssert.passes(this.crystals.mintCrystal(1, { from: owner }));
        console.log(await this.rift.getCharges(1));

        await truffleAssert.passes(this.crystals.mintCrystal(1, { from: owner }));
        console.log(await this.rift.getCharges(1));

        // assert.equal((await this.rift.getLevel((await this.rift.bags(1)).xp)), 2, "Should be level 2");

        // await truffleAssert.passes(this.rift.growTheRift(this.crystals.address, 10000001, 1, { from: owner }));
        // assert.equal((await this.rift.getLevel((await this.rift.bags(1)).xp)), 2, "Should be level 2");

        // await truffleAssert.passes(this.rift.growTheRift(this.crystals.address, 20000001, 1, { from: owner }));
        // assert.equal((await this.rift.getLevel((await this.rift.bags(1)).xp)), 2, "Should be level 2");

        // console.log(await this.crystals.mintCrystal.estimateGas(1, { from: owner }));
        // await truffleAssert.passes(this.crystals.mintCrystal(1, { from: owner }));
        // console.log(await this.crystals.mintCrystal.estimateGas(1, { from: owner }));
        // await truffleAssert.passes(this.rift.growTheRift(this.crystals.address, 30000001, 1, { from: owner }));
        // console.log(await this.crystals.mintCrystal.estimateGas(1, { from: owner }));
        // await truffleAssert.passes(this.crystals.mintCrystal(1, { from: owner }));
        // console.log(await this.crystals.mintCrystal.estimateGas(1, { from: owner }));
        // await truffleAssert.passes(this.rift.growTheRift(this.crystals.address, 40000001, 1, { from: owner }));
        // console.log(await this.crystals.mintCrystal.estimateGas(1, { from: owner }));
        // await truffleAssert.passes(this.crystals.mintCrystal(1, { from: owner }));
        // console.log(await this.crystals.mintCrystal.estimateGas(1, { from: owner }));
        // await truffleAssert.passes(this.rift.growTheRift(this.crystals.address, 50000001, 1, { from: owner }));
        // console.log(await this.crystals.mintCrystal.estimateGas(1, { from: owner }));
    });

    // it ('can interact as gloot and mloot', async function () {
    //     await this.gloot.mint(2);
    //     await this.mloot.mint(90000);
        
    //     await truffleAssert.fails(this.crystals.firstMint(2, { value: web3.utils.toWei("0.04", "ether") }))

    //     await truffleAssert.passes(this.crystals.firstMint(9997462, { value: web3.utils.toWei("0.04", "ether") }))
    //     await truffleAssert.passes(this.crystals.firstMint(90000, { value: web3.utils.toWei("0.004", "ether") }))

    //     await truffleAssert.fails(this.crystals.firstMint(9997462, { value: web3.utils.toWei("0.04", "ether") }))
    //     await truffleAssert.fails(this.crystals.firstMint(90000, { value: web3.utils.toWei("0.004", "ether") }))

    //     await truffleAssert.fails(this.rift.growTheRift(this.crystals.address, 9997462, 9997462, { from: other }));
    //     await truffleAssert.fails(this.rift.growTheRift(this.crystals.address, 90000, 90000, { from: other }));

    //     await truffleAssert.passes(this.rift.growTheRift(this.crystals.address, 9997462, 9997462, { from: owner }));
    //     await truffleAssert.passes(this.rift.growTheRift(this.crystals.address, 90000, 90000, { from: owner }));

    //     await truffleAssert.passes(this.crystals.mintCrystal(9997462, { from: owner }));

    //     await truffleAssert.passes(this.crystals.mintCrystal(90000, { from: owner }));
    // });

    // it ('can mint crystal with unregistered bag', async function () {
    //     assert.equal((await this.rift.bags(1)).xp, 0, "New bags have no XP");
    //     await truffleAssert.passes(this.crystals.firstMint(1, { value: web3.utils.toWei("0.04", "ether") }));
    //     assert.equal((await this.rift.bags(1)).xp, 50, "First quest step gives 50");
    // });

    // it('has a deploying balance', async function () {
    //     const balance = await this.mana.balanceOf(owner);
    //     assert.equal(balance.valueOf(), 1000000);
    // });

    // it ('has loot', async function () {
    //     // non owner can not transfer
    //     await truffleAssert.fails(this.loot.transferFrom(other, owner, 1));
    //     //but transferring in general works
    //     await truffleAssert.passes(
    //         this.loot.transferFrom(owner, other, 1, { from: owner }),
    //     );
    // });

    // it ('can perform a quest step', async function () {
    //     // can't be done w/o loot
    //     await truffleAssert.fails(this.quests.completeStep(this.enterRift.address, 1, 2));

    //     await this.loot.mint(2);
        
    //     await truffleAssert.passes(this.quests.completeStep(this.enterRift.address, 1, 2));
    // });

    // it ('has 50 xp after first quest step', async function () {
    //     assert.equal((await this.rift.bags(1)).xp, 0, "New bags have no XP");

    //     // performs quest step
    //     await truffleAssert.passes(this.quests.completeStep(this.enterRift.address, 1, 1));

    //     assert.equal((await this.rift.bags(1)).xp, 50, "First quest step gives 50");
    // });

    // it ('can not perform the same step twice', async function () {
    //     await truffleAssert.passes(this.quests.completeStep(this.enterRift.address, 1, 1));
    //     await truffleAssert.fails(this.quests.completeStep(this.enterRift.address, 1, 1));
    // });

    // it ('can create a crystal', async function () {
    //     await truffleAssert.fails(this.crystals.mintCrystal(1, { value: web3.utils.toWei("0", "ether") }));

    //     // // do first step for a rift charge
    //     await this.quests.completeStep(this.enterRift.address, 1, 1)
    //     assert.equal((await this.rift.bags(1)).charges, 1, "Should have 1 charge");

    //     // // use charge
    //     await truffleAssert.passes(this.crystals.mintCrystal(1, { value: web3.utils.toWei("0.02", "ether") }));
    //     assert.equal((await this.rift.bags(1)).charges, 0, "Should have 0 charges");
    //     assert.equal((await this.crystals.bags(1)).mintCount, 1, "1 Crystal minted for this bag");
    // });

    // it ('can level up a crystal', async function () {
    //     await this.quests.completeStep(this.enterRift.address, 1, 1)
    //     await this.crystals.mintCrystal(1, { value: web3.utils.toWei("0.02", "ether") });
    //     assert.equal((await this.crystals.crystalsMap(1)).level, 1, "Starts at level 1");
    //     await this.crystals.refocusCrystal(1);
    //     assert.equal((await this.crystals.crystalsMap(1)).level, 2, "Leveled up");
    // });

    // it ('can complete the first quest', async function () {
    //     // // do first step for a rift charge
    //     await this.quests.completeStep(this.enterRift.address, 1, 1)
    //     assert.equal((await this.rift.bags(1)).level, 1, "Should be level 1");

    //     // can't complete without crystal
    //     await truffleAssert.fails(this.quests.completeStep(this.enterRift.address, 2, 1));

    //     // use charge
    //     await truffleAssert.passes(this.crystals.mintCrystal(1, { value: web3.utils.toWei("0.02", "ether") }));
    //     await truffleAssert.passes(this.quests.completeStep(this.enterRift.address, 2, 1));
    //     assert.equal((await this.rift.bags(1)).level, 2, "Should level up");

    //     // can claim mana
    //     await truffleAssert.passes(this.crystals.claimCrystalMana(1));
    //     await truffleAssert.passes(this.quests.completeStep(this.enterRift.address, 3, 1));
    //     assert((await this.enterRift.bagsProgress(1)).completedQuest, "Has completed quest");
    //     assert.equal((await this.rift.bags(1)).level, 3, "Should level up");

    //     await truffleAssert.passes(this.quests.mintQuest(this.enterRift.address, 1));
    // });

    // it ('can reduce the rifts power', async function () {
    //     assert.equal((await this.rift.riftPower()), 100000, "Rift starts at 100000");
    //     await this.quests.completeStep(this.enterRift.address, 1, 1)
    //     assert.equal((await this.rift.riftPower()), 99999, "Charges reduce power");
    
    //     // // use charge
    //     await this.crystals.mintCrystal(1, { value: web3.utils.toWei("0.02", "ether") });
    //     assert.equal((await this.crystals.riftPower(1)), 1, "Potential Rift Power of Crystal");
    //     await this.crystals.refocusCrystal(1);
    //     assert.equal((await this.crystals.riftPower(1)), 1, "Potential Rift Power of Crystal");

    //     assert.equal((await this.rift.riftPower()), 99999, "Charges reduce power");

    //     // a crystal that doesn't exist should fail
    //     await truffleAssert.fails(this.rift.growTheRift(this.crystals.address, 2));
    //     // can't be burned by other user
    //     await truffleAssert.fails(this.rift.growTheRift(this.crystals.address, 1, { from: other }));
    //     // burning increases power
    //     await truffleAssert.passes(this.rift.growTheRift(this.crystals.address, 1, { from: owner }));

    //     assert.equal((await this.rift.riftPower()), 100000, "Rifts power grows");
    // });

    // it ('burning crystal increases mana gain by spin', async function () {
    //     // // use charge
    //     await this.crystals.firstMint(1, { value: web3.utils.toWei("0.04", "ether") });

    //     const startingMana = await this.mana.balanceOf(owner);
    //     // const spin = await this.crystals.getSpin(1);

    //     // // a crystal that doesn't exist should fail
    //     await truffleAssert.fails(this.rift.growTheRift(this.crystals.address, 2, 1));
    //     // // can't be burned by other user
    //     await truffleAssert.fails(this.rift.growTheRift(this.crystals.address, 1, 1, { from: other }));
    //     // // burning increases power
    //     await truffleAssert.passes(this.rift.growTheRift(this.crystals.address, 1, 1, { from: owner }));

    //     const endingMana = await this.mana.balanceOf(owner);
    //     assert.notEqual(startingMana.valueOf(), endingMana.valueOf(), "Gained Mana equal to spin");
    // });

    // it ('crystal minting behaves as expected', async function () {
    //     // // use charge
    //     await this.crystals.firstMint(1, { value: web3.utils.toWei("0.04", "ether") });

    //     const startingMana = await this.mana.balanceOf(owner);
    //     await truffleAssert.passes(this.crystals.claimCrystalMana(1));

    //     const endingMana = await this.mana.balanceOf(owner);
    //     assert.equal( endingMana - startingMana, (await this.crystals.getResonance(1)), "Gained Mana equal to 1 day * resonance");
    // });

    // it ('can buy charge', async function () {
    //     // this creates and consumes charge
    //     await this.crystals.firstMint(1, { value: web3.utils.toWei("0.04", "ether") }); 
    //     const startingMana = await this.mana.balanceOf(owner);
    //     // buy a charge
    //     await truffleAssert.passes(this.rift.buyCharge(1));
    //     assert.equal((await this.rift.bags(1)).charges, 1, "Should have 1 charge");
    //     // can't buy 2 in a day
    //     await truffleAssert.fails(this.rift.buyCharge(1));

    //     const endingMana = await this.mana.balanceOf(owner);
    //     assert.equal(startingMana - 100, endingMana, "used 100 mana to buy");
    // });
});
