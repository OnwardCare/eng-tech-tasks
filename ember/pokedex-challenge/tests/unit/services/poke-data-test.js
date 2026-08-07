import { module, test } from 'qunit';
import { setupTest } from 'pokedex-challenge/tests/helpers';

module('Unit | Service | poke-data', function (hooks) {
  setupTest(hooks);

  test('fetchPage returns shaped list entries', async function (assert) {
    const pokeData = this.owner.lookup('service:poke-data');

    const page = await pokeData.fetchPage(0, 2);

    assert.strictEqual(page.length, 2);
    assert.deepEqual(Object.keys(page[0]).sort(), [
      'id',
      'name',
      'sprite',
      'types',
    ]);
    assert.strictEqual(page[0].name, 'bulbasaur');
    assert.true(Array.isArray(page[0].types));
  });

  test('fetchPokemonDetail returns a shaped detail with a linear evolution chain', async function (assert) {
    const pokeData = this.owner.lookup('service:poke-data');

    const detail = await pokeData.fetchPokemonDetail(1);

    assert.strictEqual(detail.id, 1);
    assert.strictEqual(detail.name, 'bulbasaur');
    assert.true(Array.isArray(detail.abilities));
    assert.true(Array.isArray(detail.stats));
    assert.strictEqual(typeof detail.flavorText, 'string');

    assert.deepEqual(
      detail.evolutionStages.map((stage) => ({
        isLast: stage.isLast,
        names: stage.pokemons.map((p) => p.name),
      })),
      [
        { isLast: false, names: ['bulbasaur'] },
        { isLast: false, names: ['ivysaur'] },
        { isLast: true, names: ['venusaur'] },
      ],
    );
  });

  test('fetchJSON caches responses so repeat requests for the same URL are not refetched', async function (assert) {
    const pokeData = this.owner.lookup('service:poke-data');

    const first = await pokeData.fetchPokemon(1);
    const cacheSizeAfterFirst = pokeData.cache.size;
    const second = await pokeData.fetchPokemon(1);

    assert.strictEqual(
      pokeData.cache.size,
      cacheSizeAfterFirst,
      'no new cache entry was added on the second request',
    );
    assert.strictEqual(
      first,
      second,
      'the same cached object reference is returned',
    );
  });
});
