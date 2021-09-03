const { contract } = require('@openzeppelin/test-environment');

const Rift = contract.fromArtifact('Rift');

let tokenId = '0001';
process.argv.forEach((val, index) => {
  if (index === 2) {
    tokenId = val;
  }
});

(async () => {
  console.log('\n🔮 generating stats for #' + tokenId, '\n\n');

  const riftInstance = await Rift.new();
  const name = await riftInstance.getName(tokenId);
  const level = await riftInstance.getLevel(tokenId);
  const bonusMana = await riftInstance.getBonusMana(tokenId);
  const maxCapacity = await riftInstance.getMaxCapacity(tokenId);

  console.log('name:', name);
  console.log('level:', level);
  console.log('bonusMana:', bonusMana);
  console.log('maxCapacity:', maxCapacity, '\n');
  process.exit();
})();
