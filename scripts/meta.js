const { getArgs, setup } = require('./helpers');

const args = getArgs();

(async () => {
  console.log('\n🔮 generating meta for #' + args.seeds.join(', #'), '\n\n');

  const { crystalsMeta } = await setup();
  
  for (let i = 0; i < args.seeds.length; i++) {
    const slabs = await crystalsMeta.getSlabs(args.seeds[i]);
    console.log('\n---------\nslabs', slabs, '\n---------\n');
  }

  process.exit();
})();
