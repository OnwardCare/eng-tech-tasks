import { module, test } from 'qunit';
import { setupTest } from 'pokedex-challenge/tests/helpers';

const API = 'https://pokeapi.co/api/v2';
const CHAIN_URL = `${API}/evolution-chain/67/`;

function species(name, id) {
  return { name, url: `${API}/pokemon-species/${id}/` };
}

function pokemon(id) {
  return {
    id,
    name: `pokemon-${id}`,
    sprites: { front_default: `/sprites/${id}.png`, other: {} },
    types: [],
    abilities: [],
    stats: [],
    height: 1,
    weight: 1,
  };
}

// eevee -> {vaporeon, jolteon}
const BRANCHING_CHAIN = {
  chain: {
    species: species('eevee', 133),
    evolves_to: [
      { species: species('vaporeon', 134), evolves_to: [] },
      { species: species('jolteon', 135), evolves_to: [] },
    ],
  },
};

module('Unit | Service | poke-data', function (hooks) {
  setupTest(hooks);

  function stubRequests(service, responses) {
    service.request = async (url) => {
      if (!(url in responses)) {
        throw new Error(`unexpected request: ${url}`);
      }
      return responses[url];
    };
  }

  test('flattens a branching chain into one entry per stage', async function (assert) {
    const service = this.owner.lookup('service:poke-data');

    stubRequests(service, {
      [CHAIN_URL]: BRANCHING_CHAIN,
      [`${API}/pokemon/133`]: pokemon(133),
      [`${API}/pokemon/134`]: pokemon(134),
      [`${API}/pokemon/135`]: pokemon(135),
    });

    const stages = await service.fetchEvolutionChain(CHAIN_URL);

    assert.deepEqual(
      stages.map((stage) => stage.map((entry) => entry.name)),
      [['eevee'], ['vaporeon', 'jolteon']],
    );
    assert.deepEqual(stages[0][0], {
      id: 133,
      name: 'eevee',
      sprite: '/sprites/133.png',
    });
  });

  test('a species that does not evolve has no chain to show', async function (assert) {
    const service = this.owner.lookup('service:poke-data');

    stubRequests(service, {
      [CHAIN_URL]: {
        chain: { species: species('ditto', 132), evolves_to: [] },
      },
    });

    assert.deepEqual(await service.fetchEvolutionChain(CHAIN_URL), []);
  });

  test('a stage whose sprite fails to load still renders', async function (assert) {
    const service = this.owner.lookup('service:poke-data');

    stubRequests(service, {
      [CHAIN_URL]: BRANCHING_CHAIN,
      [`${API}/pokemon/133`]: pokemon(133),
      [`${API}/pokemon/135`]: pokemon(135),
      // 134 is deliberately absent, so its lookup throws.
    });

    const stages = await service.fetchEvolutionChain(CHAIN_URL);

    assert.deepEqual(stages[1][0], {
      id: 134,
      name: 'vaporeon',
      sprite: null,
    });
    assert.strictEqual(stages[1][1].sprite, '/sprites/135.png');
  });

  test('a failed response rejects instead of resolving to junk', async function (assert) {
    const service = this.owner.lookup('service:poke-data');

    service.request = async () => {
      throw new Error('Request failed with 404');
    };

    await assert.rejects(service.fetchPokemon(9999), /404/);
  });
});
