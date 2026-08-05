import { module, test } from 'qunit';
import {
  GEN_1_COUNT,
  idFromUrl,
  toPokemonSummary,
} from 'pokedex-challenge/utils/pokeapi';

module('Unit | Utility | pokeapi', function () {
  test('GEN_1_COUNT is 151', function (assert) {
    assert.strictEqual(GEN_1_COUNT, 151);
  });

  test('idFromUrl extracts the trailing numeric id', function (assert) {
    assert.strictEqual(
      idFromUrl('https://pokeapi.co/api/v2/pokemon-species/25/'),
      25,
    );
    assert.strictEqual(idFromUrl('https://pokeapi.co/api/v2/pokemon/1/'), 1);
  });

  test('idFromUrl handles a URL without a trailing slash', function (assert) {
    assert.strictEqual(idFromUrl('https://pokeapi.co/api/v2/pokemon/1'), 1);
  });

  test('idFromUrl returns a number, not a string', function (assert) {
    assert.strictEqual(
      typeof idFromUrl('https://pokeapi.co/api/v2/pokemon/1/'),
      'number',
    );
  });

  test('toPokemonSummary projects a raw detail response into the list-item shape', function (assert) {
    const detail = {
      id: 1,
      name: 'bulbasaur',
      height: 7,
      weight: 69,
      sprites: { front_default: 'https://example.com/bulbasaur.png' },
      types: [{ type: { name: 'grass' } }, { type: { name: 'poison' } }],
    };

    assert.deepEqual(toPokemonSummary(detail), {
      id: 1,
      name: 'bulbasaur',
      sprite: 'https://example.com/bulbasaur.png',
      types: ['grass', 'poison'],
    });
  });
});
