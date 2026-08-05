import { module, test } from 'qunit';
import { flattenEvolutionChain } from 'pokedex-challenge/utils/evolution-chain';

function speciesRef(id, name) {
  return { name, url: `https://pokeapi.co/api/v2/pokemon-species/${id}/` };
}

function node(id, name, evolvesTo = []) {
  return { species: speciesRef(id, name), evolves_to: evolvesTo };
}

module('Unit | Utility | evolution-chain', function () {
  test('flattens a linear chain into one entry per level, in order', function (assert) {
    const chain = node(1, 'bulbasaur', [
      node(2, 'ivysaur', [node(3, 'venusaur')]),
    ]);

    assert.deepEqual(flattenEvolutionChain(chain), [
      [{ id: 1, name: 'bulbasaur' }],
      [{ id: 2, name: 'ivysaur' }],
      [{ id: 3, name: 'venusaur' }],
    ]);
  });

  test('groups branching evolutions as siblings within the same level', function (assert) {
    const chain = node(133, 'eevee', [
      node(134, 'vaporeon'),
      node(135, 'jolteon'),
      node(136, 'flareon'),
    ]);

    assert.deepEqual(flattenEvolutionChain(chain), [
      [{ id: 133, name: 'eevee' }],
      [
        { id: 134, name: 'vaporeon' },
        { id: 135, name: 'jolteon' },
        { id: 136, name: 'flareon' },
      ],
    ]);
  });

  test('a species with no evolutions produces a single level with one entry', function (assert) {
    const chain = node(128, 'tauros');

    assert.deepEqual(flattenEvolutionChain(chain), [
      [{ id: 128, name: 'tauros' }],
    ]);
  });
});
