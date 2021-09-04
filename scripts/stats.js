const { contract } = require('@openzeppelin/test-environment');

const { getArgs } = require('./helpers');

const Crystals = contract.fromArtifact('Crystals');

const args = getArgs();

(async () => {
  console.log('\n🔮 generating stats for #' + args.seeds.join(', #'), '\n\n');

  const crystalInstance = await Crystals.new();

  const printStatsForId =  async (id) => {
    const name = await crystalInstance.getName(id);
    const level = await crystalInstance.getLevel(id);
    const bonusMana = await crystalInstance.getBonusMana(id);
    const maxCapacity = await crystalInstance.getMaxCapacity(id);

    const lvl = level.toNumber();
    console.log('#' + id);
    console.log('name:', name, lvl > 1 ? ('+' + (lvl - 1)) : '');
    console.log('level:', level.toNumber());
    console.log('bonusMana:', bonusMana.toNumber());
    console.log('maxCapacity:', maxCapacity.toNumber(), '\n');
  };

  for (let i = 0; i < args.seeds.length; i++) {
    await printStatsForId(args.seeds[i]);
  }

  process.exit();
})();
