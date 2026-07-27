import { module, test } from 'qunit';
import { setupTest } from 'pokedex-challenge/tests/helpers';

module('Unit | Service | poke-data', function (hooks) {
  setupTest(hooks);

  hooks.beforeEach(function () {
    this.originalFetch = globalThis.fetch;
    this.fetchCalls = 0;
  });

  hooks.afterEach(function () {
    globalThis.fetch = this.originalFetch;
  });

  test('fetchPokemon caches by id so repeated calls only fetch once', async function (assert) {
    globalThis.fetch = async () => {
      this.fetchCalls++;
      return { ok: true, json: async () => ({ id: 25, name: 'pikachu' }) };
    };

    const pokeData = this.owner.lookup('service:poke-data');

    const [first, second] = await Promise.all([
      pokeData.fetchPokemon(25),
      pokeData.fetchPokemon(25),
    ]);
    await pokeData.fetchPokemon(25);

    assert.strictEqual(this.fetchCalls, 1, 'only one network request made');
    assert.strictEqual(first, second, 'both callers got the same result');
  });

  test('fetchPokemon does not cache a failed request', async function (assert) {
    globalThis.fetch = async () => {
      this.fetchCalls++;
      return { ok: false, json: async () => ({}) };
    };

    const pokeData = this.owner.lookup('service:poke-data');

    await assert.rejects(pokeData.fetchPokemon('does-not-exist'));
    await assert.rejects(pokeData.fetchPokemon('does-not-exist'));

    assert.strictEqual(
      this.fetchCalls,
      2,
      'a failed lookup is retried, not cached forever',
    );
  });
});
