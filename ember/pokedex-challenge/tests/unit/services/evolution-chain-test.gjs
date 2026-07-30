import { module, test } from 'qunit';
import { setupTest } from 'pokedex-challenge/tests/helpers';

module('Unit | Service | evolution-chain', function (hooks) {
  setupTest(hooks);

  // Setup: mock fetch for each test
  hooks.beforeEach(function () {
    const originalFetch = window.fetch;

    this.mockResponses = (responses) => {
      // responses: { [url]: { ok: boolean, json: () => Promise } }
      window.fetch = async (url) => {
        if (responses[url]) {
          return responses[url];
        }
        throw new Error(`No mock for ${url}`);
      };
    };

    this.mockFetchError = async () => {
      window.fetch = async () => {
        throw new Error('Network error');
      };
    };

    // Restore original fetch after each test
    hooks.afterEach(() => {
      window.fetch = originalFetch;
    });
  });

  // Test: parseChain with linear evolution chain (Bulbasaur)
  test('parseChain parses linear chain correctly', function (assert) {
    const service = this.owner.lookup('service:evolution-chain');

    const bulbasaurChain = {
      species: {
        name: 'bulbasaur',
        url: 'https://pokeapi.co/api/v2/pokemon-species/1/',
      },
      evolves_to: [
        {
          species: {
            name: 'ivysaur',
            url: 'https://pokeapi.co/api/v2/pokemon-species/2/',
          },
          evolves_to: [
            {
              species: {
                name: 'venusaur',
                url: 'https://pokeapi.co/api/v2/pokemon-species/3/',
              },
              evolves_to: [],
            },
          ],
        },
      ],
    };

    const stages = service.parseChain(bulbasaurChain);

    assert.strictEqual(stages.length, 3, 'returns all 3 stages');
    assert.strictEqual(stages[0].name, 'bulbasaur', 'first stage is bulbasaur');
    assert.strictEqual(stages[0].id, 1, 'bulbasaur has correct ID');
    assert.strictEqual(stages[1].name, 'ivysaur');
    assert.strictEqual(stages[2].name, 'venusaur');
  });

  // Test: parseChain with branching evolution chain (Eevee)
  test('parseChain handles branching chains', function (assert) {
    const service = this.owner.lookup('service:evolution-chain');

    const eeveeChain = {
      species: {
        name: 'eevee',
        url: 'https://pokeapi.co/api/v2/pokemon-species/133/',
      },
      evolves_to: [
        {
          species: {
            name: 'vaporeon',
            url: 'https://pokeapi.co/api/v2/pokemon-species/134/',
          },
          evolves_to: [],
        },
        {
          species: {
            name: 'jolteon',
            url: 'https://pokeapi.co/api/v2/pokemon-species/135/',
          },
          evolves_to: [],
        },
        {
          species: {
            name: 'flareon',
            url: 'https://pokeapi.co/api/v2/pokemon-species/136/',
          },
          evolves_to: [],
        },
      ],
    };

    const stages = service.parseChain(eeveeChain);

    assert.strictEqual(stages.length, 4, 'returns eevee plus all evolutions');
    assert.strictEqual(stages[0].name, 'eevee');
    assert.true(stages.some((s) => s.name === 'vaporeon'));
    assert.true(stages.some((s) => s.name === 'jolteon'));
    assert.true(stages.some((s) => s.name === 'flareon'));
  });

  // Test: parseChain with single-stage Pokémon (no evolution)
  test('parseChain handles single-stage Pokémon', function (assert) {
    const service = this.owner.lookup('service:evolution-chain');

    const dittoChain = {
      species: {
        name: 'ditto',
        url: 'https://pokeapi.co/api/v2/pokemon-species/132/',
      },
      evolves_to: [],
    };

    const stages = service.parseChain(dittoChain);

    assert.strictEqual(stages.length, 1);
    assert.strictEqual(stages[0].name, 'ditto');
    assert.strictEqual(stages[0].id, 132);
  });

  // Test: parseChain returns empty array for null/undefined input
  test('parseChain returns empty array for null/undefined input', function (assert) {
    const service = this.owner.lookup('service:evolution-chain');

    assert.deepEqual(service.parseChain(null), []);
    assert.deepEqual(service.parseChain(undefined), []);
    assert.deepEqual(service.parseChain({}), []);
  });

  // Test: parseChain skips stages without URL
  test('parseChain skips stages without URL', function (assert) {
    const service = this.owner.lookup('service:evolution-chain');

    const chainWithoutUrl = {
      species: { name: 'bulbasaur' }, // No URL
      evolves_to: [],
    };

    const stages = service.parseChain(chainWithoutUrl);

    assert.strictEqual(stages.length, 0, 'skips stage without URL');
  });

  // Test: fetchEvolutionChain fetches and returns linear chain
  test('fetchEvolutionChain fetches and returns linear chain', async function (assert) {
    const service = this.owner.lookup('service:evolution-chain');

    const speciesResponse = {
      id: 1,
      name: 'bulbasaur',
      evolution_chain: {
        url: 'https://pokeapi.co/api/v2/evolution-chain/1/',
      },
    };

    const chainResponse = {
      id: 1,
      chain: {
        species: {
          name: 'bulbasaur',
          url: 'https://pokeapi.co/api/v2/pokemon-species/1/',
        },
        evolves_to: [
          {
            species: {
              name: 'ivysaur',
              url: 'https://pokeapi.co/api/v2/pokemon-species/2/',
            },
            evolves_to: [
              {
                species: {
                  name: 'venusaur',
                  url: 'https://pokeapi.co/api/v2/pokemon-species/3/',
                },
                evolves_to: [],
              },
            ],
          },
        ],
      },
    };

    this.mockResponses({
      'https://pokeapi.co/api/v2/pokemon-species/1': {
        ok: true,
        json: async () => speciesResponse,
      },
      'https://pokeapi.co/api/v2/evolution-chain/1/': {
        ok: true,
        json: async () => chainResponse,
      },
    });

    const result = await service.fetchEvolutionChain(1);

    assert.ok(result);
    assert.strictEqual(result.stages.length, 3);
    assert.true(result.hasEvolution);
    assert.strictEqual(result.stages[0].name, 'bulbasaur');
    assert.strictEqual(result.stages[1].name, 'ivysaur');
    assert.strictEqual(result.stages[2].name, 'venusaur');
  });

  // Test: fetchEvolutionChain returns single-stage for Pokémon without evolution
  test('fetchEvolutionChain returns single-stage for Pokémon without evolution', async function (assert) {
    const service = this.owner.lookup('service:evolution-chain');

    const speciesResponse = {
      id: 132,
      name: 'ditto',
      evolution_chain: null,
    };

    this.mockResponses({
      'https://pokeapi.co/api/v2/pokemon-species/132': {
        ok: true,
        json: async () => speciesResponse,
      },
    });

    const result = await service.fetchEvolutionChain(132);

    assert.ok(result);
    assert.strictEqual(result.stages.length, 1);
    assert.false(result.hasEvolution);
    assert.strictEqual(result.stages[0].name, 'ditto');
  });

  // Test: fetchEvolutionChain caches results and avoids repeated fetches
  test('fetchEvolutionChain caches results and avoids repeated fetches', async function (assert) {
    const service = this.owner.lookup('service:evolution-chain');
    let fetchCount = 0;

    const speciesResponse = {
      id: 1,
      name: 'bulbasaur',
      evolution_chain: {
        url: 'https://pokeapi.co/api/v2/evolution-chain/1/',
      },
    };

    const chainResponse = {
      id: 1,
      chain: {
        species: {
          name: 'bulbasaur',
          url: 'https://pokeapi.co/api/v2/pokemon-species/1/',
        },
        evolves_to: [],
      },
    };

    window.fetch = async (url) => {
      fetchCount++;
      if (url.includes('pokemon-species')) {
        return { ok: true, json: async () => speciesResponse };
      }
      if (url.includes('evolution-chain')) {
        return { ok: true, json: async () => chainResponse };
      }
      throw new Error(`Unknown URL: ${url}`);
    };

    // First fetch
    await service.fetchEvolutionChain(1);
    const firstFetchCount = fetchCount;

    // Second fetch (should use cache)
    const result2 = await service.fetchEvolutionChain(1);
    const secondFetchCount = fetchCount;

    assert.strictEqual(firstFetchCount, 2, 'first call makes 2 requests');
    assert.strictEqual(secondFetchCount, 2, 'second call uses cache');
    assert.ok(result2);
  });

  // Test: fetchEvolutionChain returns null on species fetch error
  test('fetchEvolutionChain returns null on species fetch error', async function (assert) {
    const service = this.owner.lookup('service:evolution-chain');

    this.mockResponses({
      'https://pokeapi.co/api/v2/pokemon-species/9999': {
        ok: false,
        status: 404,
        json: async () => ({}),
      },
    });

    const result = await service.fetchEvolutionChain(9999);

    assert.strictEqual(result, null);
  });

  // Test: fetchEvolutionChain returns null on chain fetch error
  test('fetchEvolutionChain returns null on chain fetch error', async function (assert) {
    const service = this.owner.lookup('service:evolution-chain');

    const speciesResponse = {
      id: 1,
      name: 'bulbasaur',
      evolution_chain: {
        url: 'https://pokeapi.co/api/v2/evolution-chain/1/',
      },
    };

    this.mockResponses({
      'https://pokeapi.co/api/v2/pokemon-species/1': {
        ok: true,
        json: async () => speciesResponse,
      },
      'https://pokeapi.co/api/v2/evolution-chain/1/': {
        ok: false,
        status: 500,
        json: async () => ({}),
      },
    });

    const result = await service.fetchEvolutionChain(1);

    assert.strictEqual(result, null);
  });

  // Test: fetchEvolutionChain returns null on network error
  test('fetchEvolutionChain returns null on network error', async function (assert) {
    const service = this.owner.lookup('service:evolution-chain');

    this.mockFetchError();

    const result = await service.fetchEvolutionChain(1);

    assert.strictEqual(result, null);
  });
});
