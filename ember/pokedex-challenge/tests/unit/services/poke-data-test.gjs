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
});
