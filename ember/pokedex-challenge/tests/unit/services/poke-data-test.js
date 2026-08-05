import { module, test } from 'qunit';
import { setupTest } from 'pokedex-challenge/tests/helpers';

function stubFetch(context, handler) {
  window.fetch = async (url) => {
    context.fetchCalls.push(url);
    return handler(url);
  };
}

module('Unit | Service | poke-data', function (hooks) {
  setupTest(hooks);

  hooks.beforeEach(function () {
    this.originalFetch = window.fetch;
    this.fetchCalls = [];
  });

  hooks.afterEach(function () {
    window.fetch = this.originalFetch;
  });

  test('fetchPokemon requests the correct URL and parses the response', async function (assert) {
    const pokeData = this.owner.lookup('service:poke-data');
    stubFetch(this, () => ({
      json: async () => ({ id: 25, name: 'pikachu' }),
    }));

    const result = await pokeData.fetchPokemon(25);

    assert.deepEqual(this.fetchCalls, ['https://pokeapi.co/api/v2/pokemon/25']);
    assert.deepEqual(result, { id: 25, name: 'pikachu' });
  });

  test('fetchSpecies requests the correct URL', async function (assert) {
    const pokeData = this.owner.lookup('service:poke-data');
    stubFetch(this, () => ({ json: async () => ({ id: 25 }) }));

    await pokeData.fetchSpecies(25);

    assert.deepEqual(this.fetchCalls, [
      'https://pokeapi.co/api/v2/pokemon-species/25',
    ]);
  });

  test('fetchList requests the correct URL with offset and limit', async function (assert) {
    const pokeData = this.owner.lookup('service:poke-data');
    stubFetch(this, () => ({ json: async () => ({ results: [] }) }));

    await pokeData.fetchList(20, 40);

    assert.deepEqual(this.fetchCalls, [
      'https://pokeapi.co/api/v2/pokemon?limit=40&offset=20',
    ]);
  });

  test('fetchEvolutionChain requests the given URL as-is', async function (assert) {
    const pokeData = this.owner.lookup('service:poke-data');
    stubFetch(this, () => ({ json: async () => ({ chain: {} }) }));

    await pokeData.fetchEvolutionChain(
      'https://pokeapi.co/api/v2/evolution-chain/1/',
    );

    assert.deepEqual(this.fetchCalls, [
      'https://pokeapi.co/api/v2/evolution-chain/1/',
    ]);
  });

  test('caches repeated calls for the same id', async function (assert) {
    const pokeData = this.owner.lookup('service:poke-data');
    stubFetch(this, () => ({
      json: async () => ({ id: 1, name: 'bulbasaur' }),
    }));

    await pokeData.fetchPokemon(1);
    await pokeData.fetchPokemon(1);

    assert.strictEqual(this.fetchCalls.length, 1);
  });

  test('does not share a cache entry between different ids', async function (assert) {
    const pokeData = this.owner.lookup('service:poke-data');
    stubFetch(this, (url) => ({ json: async () => ({ url }) }));

    await pokeData.fetchPokemon(1);
    await pokeData.fetchPokemon(2);

    assert.strictEqual(this.fetchCalls.length, 2);
  });

  test('normalizes cache keys so a number and a string id share a cache entry', async function (assert) {
    const pokeData = this.owner.lookup('service:poke-data');
    stubFetch(this, () => ({
      json: async () => ({ id: 1, name: 'bulbasaur' }),
    }));

    await pokeData.fetchPokemon(1);
    await pokeData.fetchPokemon('1');

    assert.strictEqual(this.fetchCalls.length, 1);
  });

  test('dedupes concurrent requests for the same id', async function (assert) {
    const pokeData = this.owner.lookup('service:poke-data');
    stubFetch(this, () => ({
      json: async () => ({ id: 1, name: 'bulbasaur' }),
    }));

    const [first, second] = await Promise.all([
      pokeData.fetchPokemon(1),
      pokeData.fetchPokemon(1),
    ]);

    assert.strictEqual(this.fetchCalls.length, 1);
    assert.strictEqual(first, second);
  });

  test('evicts a failed request from the cache so a retry re-fetches', async function (assert) {
    const pokeData = this.owner.lookup('service:poke-data');
    stubFetch(this, () => {
      throw new Error('network down');
    });

    await assert.rejects(pokeData.fetchPokemon(1));
    assert.strictEqual(this.fetchCalls.length, 1);

    stubFetch(this, () => ({
      json: async () => ({ id: 1, name: 'bulbasaur' }),
    }));

    const result = await pokeData.fetchPokemon(1);

    assert.strictEqual(this.fetchCalls.length, 2);
    assert.deepEqual(result, { id: 1, name: 'bulbasaur' });
  });
});
