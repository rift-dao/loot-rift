const { contract } = require('@openzeppelin/test-environment');

const { getArgs, hasFlag } = require('./helpers');

const Crystals = contract.fromArtifact('Crystals');

const args = getArgs();

(async () => {
  const crystalInstance = await Crystals.new();
  const printStatsForId =  async (id) => {
    const name = await crystalInstance.getName(id);
    const level = await crystalInstance.getLevel(id);
    const resonance = await crystalInstance.getResonance(id);
    const spin = await crystalInstance.getSpin(id);

    const lvl = level.toNumber();
    console.log('#' + id);
    console.log('name:', name, lvl > 1 ? ('+' + (lvl - 1)) : '');
    console.log('level:', level.toNumber());
    console.log('resonance:', resonance.toNumber());
    console.log('spin:', spin.toNumber(), '\n');
  };

  let from = 0;
  let to = args.seeds.length;

  const isRange = hasFlag('-r') || hasFlag('--range');

  if (isRange) {
    from = parseInt(args.seeds[0]);
    to = parseInt(args.seeds[1]);

    console.log('\n🔮 generating stats for #' + from, '- #' + to, '\n\n');
  } else {
    console.log('\n🔮 generating stats for #' + args.seeds.join(', #'), '\n\n');
  }

  for (let i = from; i < to; i++) {
    await printStatsForId(isRange ? i : args.seeds[i]);
  }

  process.exit();
})();
