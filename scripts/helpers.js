
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

  const mana = await Mana.new();
  const crystals = await Crystals.new();
  const crystalsMetadata = await CrystalsMetadata.new();

  await crystals.ownerSetMetadataAddress(crystalsMetadata.address);
  await crystalsMetadata.setCrystalsAddress(crystals.address);
  await mana.ownerSetCContractAddress(crystals.address);

  await crystals.ownerInit(
    mana.address,
    '0x0000000000000000000000000000000000000000',
    '0x0000000000000000000000000000000000000000'
  );

  return {
    crystals,
    crystalsMetadata,
    mana,
  };
};

module.exports = {
  decodeToken,
  getArgs,
  hasFlag,
  setup,
  MAX_CRYSTALS: 10000000,
  RESERVED_OFFSET: 9900000,
};
