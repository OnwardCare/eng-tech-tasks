import { module, test } from 'qunit';
import { idFromUrl } from 'pokedex-challenge/utils/poke-api';

module('Unit | Utility | poke-api', function () {
  test('idFromUrl pulls the trailing id out of a resource url', function (assert) {
    assert.strictEqual(
      idFromUrl('https://pokeapi.co/api/v2/pokemon-species/25/'),
      25,
    );
    assert.strictEqual(
      idFromUrl('https://pokeapi.co/api/v2/pokemon-species/25'),
      25,
    );
    assert.strictEqual(idFromUrl(undefined), null);
    assert.strictEqual(idFromUrl('not-a-url'), null);
  });
});
