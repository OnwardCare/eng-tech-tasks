import { module, test } from 'qunit';
import {
  idFromUrl,
  pathsFromChain,
} from 'pokedex-challenge/utils/evolution-chain';

function species(id, name, evolvesTo = []) {
  return {
    species: {
      name,
      url: `https://pokeapi.co/api/v2/pokemon-species/${id}/`,
    },
    evolves_to: evolvesTo,
  };
}

function names(paths) {
  return paths.map((path) => path.map((entry) => entry.name));
}

module('Unit | Utility | evolution-chain', function () {
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

  test('pathsFromChain returns a linear line as a single path', function (assert) {
    const chain = species(1, 'bulbasaur', [
      species(2, 'ivysaur', [species(3, 'venusaur')]),
    ]);

    assert.deepEqual(pathsFromChain(chain), [
      [
        { id: 1, name: 'bulbasaur' },
        { id: 2, name: 'ivysaur' },
        { id: 3, name: 'venusaur' },
      ],
    ]);
  });

  test('pathsFromChain returns one full path per branch', function (assert) {
    const chain = species(133, 'eevee', [
      species(134, 'vaporeon'),
      species(135, 'jolteon'),
      species(136, 'flareon'),
    ]);

    assert.deepEqual(names(pathsFromChain(chain)), [
      ['eevee', 'vaporeon'],
      ['eevee', 'jolteon'],
      ['eevee', 'flareon'],
    ]);
  });

  test('pathsFromChain repeats the shared prefix of a mid-line branch', function (assert) {
    const chain = species(60, 'poliwag', [
      species(61, 'poliwhirl', [
        species(62, 'poliwrath'),
        species(186, 'politoed'),
      ]),
    ]);

    assert.deepEqual(names(pathsFromChain(chain)), [
      ['poliwag', 'poliwhirl', 'poliwrath'],
      ['poliwag', 'poliwhirl', 'politoed'],
    ]);
  });

  test('pathsFromChain handles pokemon that do not evolve', function (assert) {
    assert.deepEqual(pathsFromChain(species(83, 'farfetchd')), [
      [{ id: 83, name: 'farfetchd' }],
    ]);
  });

  test('pathsFromChain handles a missing chain', function (assert) {
    assert.deepEqual(pathsFromChain(undefined), []);
    assert.deepEqual(pathsFromChain(null), []);
  });
});
