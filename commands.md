## Testing
`truffle develop` or `truffle console`
> `migrate`

### Setup
```js
mana = await Mana.deployed()
crystals = await Crystals.deployed()
crystals.ownerUpdateCollab(0, crystals.address, 10, 'Void')
```

### Mint
```js
await crystals.testMint(1)
crystals.mintCrystal(9900001, { value: web3.utils.toWei('0.03', 'ether') })
await crystals.testMint(8001)
```

### Register
```js
crystals.testRegister(2)
crystals.registerCrystalCollab(8001, 0)
```

### Read
```js
await crystals.ownerOf(1);
await crystals.tokenURI(1);
(await crystals.crystals(9900001).then(a => a.tokenId)).toString()
(await crystals.collabs(0).then(a => a.levelBonus)).toString()
(await mana.balanceOf(accounts[0])) / 1
(await crystals.mintedCrystals()) / 1
```


## Browser Testing
> Paste in browser console, replace `token` with string returned by `tokenURI`
```js
JSON.parse(atob('token'));
```


## Deploy Steps

1. `truffle migrate --reset --network ropsten`
2. `truffle run verify Mana Crystals CrystalsMetadata CrystalManaCalculator --network ropsten`

---

## Misc

### Contract testRegister
```js
// test register
function testRegister(uint256 bagId) external unminted(bagId + (MAX_CRYSTALS * bags[bagId].generationsMinted)) nonReentrant {
    require(bagId <= MAX_CRYSTALS, "INV");
    require(crystalsMap[bagId + (MAX_CRYSTALS * bags[bagId].generationsMinted)].level == 0, "REG");

    uint256 cost = 0;
    if (bags[bagId].generationsMinted > 0) {
        require(genReq[bags[bagId].generationsMinted + 1].manaCost > 0, "GEN NOT AVL"); 
        cost = getRegistrationCost(bags[bagId].generationsMinted + 1);
        if (!isOGCrystal(bagId)) cost = cost / 10;
    }

    IMANA(manaAddress).burn(_msgSender(), cost);

    generationRegistry[bags[bagId].generationsMinted + 1] += 1;
    
    // set the source bag bagId
    crystalsMap[bagId + (MAX_CRYSTALS * bags[bagId].generationsMinted)].level = 1;
    registeredCrystals += 1;
    crystalsMap[bagId + (MAX_CRYSTALS * bags[bagId].generationsMinted)].regNum = registeredCrystals;
}
```