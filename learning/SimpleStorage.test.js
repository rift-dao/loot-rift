const { accounts, contract } = require('@openzeppelin/test-environment');
const { BN } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

const SimpleStorage = contract.fromArtifact('SimpleStorage'); // Loads a compiled contract

describe('SimpleStorage', () => {
    it('should store a value', async () => {
        const simpleStorageInstance = await SimpleStorage.new();
        // Set value of 89
        await simpleStorageInstance.set(89, { from: accounts[0] });
        // Get stored value
        const storedData = await simpleStorageInstance.get();
        expect(storedData).to.be.bignumber.equal(new BN(89));
    });
});
