import { module, test } from 'qunit';
import { setupTest } from 'pokedex-challenge/tests/helpers';

const BASE_URL = 'https://pokeapi.co/api/v2';

const RESPONSES = {
  [`${BASE_URL}/pokemon-species/1`]: {
    evolution_chain: { url: `${BASE_URL}/evolution-chain/1/` },
  },
  [`${BASE_URL}/evolution-chain/1/`]: {
    chain: {
      species: { name: 'bulbasaur', url: `${BASE_URL}/pokemon-species/1/` },
      evolves_to: [
        {
          species: { name: 'ivysaur', url: `${BASE_URL}/pokemon-species/2/` },
          evolves_to: [
            {
              species: {
                name: 'venusaur',
                url: `${BASE_URL}/pokemon-species/3/`,
              },
              evolves_to: [],
            },
          ],
        },
      ],
    },
  },
  [`${BASE_URL}/pokemon/1`]: {
    id: 1,
    name: 'bulbasaur',
    sprites: { front_default: '/1.png' },
  },
  [`${BASE_URL}/pokemon/2`]: {
    id: 2,
    name: 'ivysaur',
    sprites: { front_default: '/2.png' },
  },
};

module('Unit | Service | poke-data', function (hooks) {
  setupTest(hooks);

  hooks.beforeEach(function () {
    this.requestedUrls = [];
    this.originalFetch = globalThis.fetch;

    globalThis.fetch = (url) => {
      this.requestedUrls.push(url);

      const body = RESPONSES[url];

      return Promise.resolve({
        ok: Boolean(body),
        status: body ? 200 : 404,
        json: () => Promise.resolve(body),
      });
    };
  });

  hooks.afterEach(function () {
    globalThis.fetch = this.originalFetch;
  });

  test('fetchEvolutionPaths walks species -> chain -> paths', async function (assert) {
    const service = this.owner.lookup('service:poke-data');

    const paths = await service.fetchEvolutionPaths(1);

    assert.deepEqual(paths, [
      [
        { id: 1, name: 'bulbasaur', sprite: '/1.png' },
        { id: 2, name: 'ivysaur', sprite: '/2.png' },
        { id: 3, name: 'venusaur', sprite: null },
      ],
    ]);
  });

  test('identical requests are only issued once', async function (assert) {
    const service = this.owner.lookup('service:poke-data');

    await Promise.all([
      service.fetchEvolutionPaths(1),
      service.fetchEvolutionPaths(1),
    ]);
    await service.fetchPokemon(1);

    assert.strictEqual(
      this.requestedUrls.filter((url) => url === `${BASE_URL}/pokemon/1`)
        .length,
      1,
    );
    assert.strictEqual(
      this.requestedUrls.filter(
        (url) => url === `${BASE_URL}/pokemon-species/1`,
      ).length,
      1,
    );
  });

  test('failed requests reject and are not cached', async function (assert) {
    const service = this.owner.lookup('service:poke-data');

    await assert.rejects(service.fetchPokemon(999), /failed with 404/);
    await assert.rejects(service.fetchPokemon(999), /failed with 404/);

    assert.strictEqual(
      this.requestedUrls.filter((url) => url === `${BASE_URL}/pokemon/999`)
        .length,
      2,
      'a failed request can be retried',
    );
  });
});
