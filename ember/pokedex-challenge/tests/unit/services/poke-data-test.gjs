import { module, test } from 'qunit';
import { setupTest } from 'pokedex-challenge/tests/helpers';

module('Unit | Service | poke-data', function (hooks) {
  setupTest(hooks);

  test('fetchPage fetches list entries and their details in parallel', async function (assert) {
    const pokeData = this.owner.lookup('service:poke-data');

    const page = await pokeData.fetchPage(0, 3);

    assert.deepEqual(
      page.map((p) => p.name),
      ['bulbasaur', 'ivysaur', 'venusaur'],
    );
    assert.ok(
      page.every((p) => typeof p.id === 'number'),
      'each entry has a numeric id',
    );
    assert.ok(
      page.every((p) => typeof p.sprite === 'string' && p.sprite.length > 0),
      'each entry has a sprite url',
    );
    assert.ok(
      page.every((p) => Array.isArray(p.types) && p.types.length > 0),
      'each entry has types',
    );
  });

  test('caches repeat calls for the same url instead of refetching', async function (assert) {
    const pokeData = this.owner.lookup('service:poke-data');
    const originalFetch = window.fetch;
    let callCount = 0;
    window.fetch = (...args) => {
      callCount++;
      return originalFetch(...args);
    };

    try {
      await pokeData.fetchPokemon(4);
      await pokeData.fetchPokemon(4);

      assert.strictEqual(
        callCount,
        1,
        'the second call reused the cached response instead of refetching',
      );
    } finally {
      window.fetch = originalFetch;
    }
  });

  test('dedupes concurrent calls for the same url into a single request', async function (assert) {
    const pokeData = this.owner.lookup('service:poke-data');
    const originalFetch = window.fetch;
    let callCount = 0;
    window.fetch = (...args) => {
      callCount++;
      return originalFetch(...args);
    };

    try {
      const [a, b] = await Promise.all([
        pokeData.fetchSpecies(1),
        pokeData.fetchSpecies(1),
      ]);

      assert.strictEqual(
        callCount,
        1,
        'only one network request was made for two concurrent callers',
      );
      assert.strictEqual(a, b, 'both callers receive the exact same response');
    } finally {
      window.fetch = originalFetch;
    }
  });
});
