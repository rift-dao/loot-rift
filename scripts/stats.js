const { contract } = require('@openzeppelin/test-environment');

const { getArgs, hasFlag, GEN_THRESH } = require('./helpers');

const Crystals = contract.fromArtifact('Crystals');
const Mana = contract.fromArtifact('Mana');

const args = getArgs();

(async () => {
  const manaInstance = await Mana.new();
  const crystalInstance = await Crystals.new();

  crystalInstance.ownerInit(
    manaInstance.address,
    '0x0000000000000000000000000000000000000000',
    '0x0000000000000000000000000000000000000000'
  );
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
  let tokenId = 1;

  const isRange = hasFlag('-r') || hasFlag('--range');
  const withLevels = hasFlag('-l') || hasFlag('--levels');

  if (isRange) {
    from = parseInt(args.seeds[0]);
    to = parseInt(args.seeds[1]);

    console.log('\n🔮 generating stats for #' + from, ' - #' + to, '\n\n');
  } else if (withLevels) {
    tokenId = parseInt(args.seeds[0]);
    from = parseInt(args.seeds[1]);
    to = parseInt(args.seeds[2]);

    console.log('\n🔮 generating stats for #' + tokenId + ' - Lvl' + from + '-' + to, '\n\n');
  } else {
    console.log('\n🔮 generating stats for #' + args.seeds.join(', #'), '\n\n');
  }

  if (withLevels) {
    const tokens = [];

    for (let i = from; i <= to; i++) {
      tokens.push(printStatsForId(tokenId + (GEN_THRESH * (i - 1))));
    }

    await Promise.all(tokens);
  } else {
    for (let i = from; i < to; i++) {
      await printStatsForId(isRange ? i : args.seeds[i]);
    }
  }

  process.exit();
})();
