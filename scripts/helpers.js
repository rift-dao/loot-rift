// const open = require('open');
const { contract } = require('@openzeppelin/test-environment');

const decodeToken = (encodedToken) => {
  const jsonEncoded = encodedToken.substring(29);
  return JSON.parse(Buffer.from(jsonEncoded, 'base64').toString());
};

const getArgs = () => {
  const output = {
    flags: [],
    seeds: [],
  };

  process.argv.slice(2).forEach(arg => {
    const isFlag = arg.indexOf('-') === 0;

    if (isFlag) {
      output.flags.push(arg);
    } else {
      output.seeds.push(arg);
    }
  });
  
  return output;
};

const hasFlag = (flag) => {
  return getArgs().flags.indexOf(flag) !== -1;
};

const setup = async () => {
  const Crystals = contract.fromArtifact('Crystals');
  const CrystalsMetadata = contract.fromArtifact('CrystalsMetadata');
  const Mana = contract.fromArtifact('Mana');
  const Rift = contract.fromArtifact('Rift');
  const Quest = contract.fromArtifact('RiftQuests');
  const EnterRift = contract.fromArtifact('EnterTheRift');

  const mana = await Mana.new();
  const crystals = await Crystals.new(mana.address);
  const crystalsMeta = await CrystalsMetadata.new(crystals.address);
  const rift = await Rift.new();
  const quest = await Quest.new(rift.address);
  const enterRift = await EnterRift.new(quest.address, crystals.address, mana.address);
  
  const promises = [
    crystals.ownerSetMetadataAddress(crystalsMeta.address),
    mana.addController(crystals.address),
  ];

  await Promise.all(promises);

  return { crystals, crystalsMeta, mana, enterRift };
}

module.exports = {
  decodeToken,
  getArgs,
  hasFlag,
  setup,
  GEN_THRESH: 10000000,
  RESERVED_OFFSET: 9900000,
};
