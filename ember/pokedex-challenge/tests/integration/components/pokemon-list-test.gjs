import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import {
  render,
  find,
  findAll,
  click,
  fillIn,
  waitUntil,
} from '@ember/test-helpers';
import PokemonList from 'pokedex-challenge/components/pokemon-list';

function pokemon(id, name) {
  return {
    id,
    name,
    sprite: `https://example.com/${name}.png`,
    types: ['normal'],
  };
}

function stubFetch(context, { list } = {}) {
  context.originalFetch = window.fetch;
  window.fetch = async (url) => {
    if (list && url.includes('/pokemon?')) {
      return { json: async () => list };
    }
    const match = url.match(/\/pokemon\/(\d+)\/?$/);
    if (match) {
      const id = Number(match[1]);
      return {
        json: async () => ({
          id,
          name: `pokemon-${id}`,
          sprites: {
            front_default: `https://example.com/${id}.png`,
            other: {
              'official-artwork': {
                front_default: `https://example.com/${id}.png`,
              },
            },
          },
          types: [{ type: { name: 'normal' } }],
        }),
      };
    }
    throw new Error(`Unhandled fetch in test: ${url}`);
  };
}

module('Integration | Component | pokemon-list', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    stubFetch(this);
  });

  hooks.afterEach(function () {
    window.fetch = this.originalFetch;
  });

  test('renders the given pokemon sorted by id', async function (assert) {
    const pokemonArg = [
      pokemon(3, 'charmander'),
      pokemon(1, 'bulbasaur'),
      pokemon(2, 'ivysaur'),
    ];

    await render(<template><PokemonList @pokemon={{pokemonArg}} /></template>);

    assert.deepEqual(
      findAll('.pokemon-name').map((el) => el.textContent.trim()),
      ['bulbasaur', 'ivysaur', 'charmander'],
    );
  });

  test('does not mutate the passed-in pokemon array when sorting', async function (assert) {
    const pokemonArg = [
      pokemon(3, 'charmander'),
      pokemon(1, 'bulbasaur'),
      pokemon(2, 'ivysaur'),
    ];

    await render(<template><PokemonList @pokemon={{pokemonArg}} /></template>);

    assert.deepEqual(
      pokemonArg.map((p) => p.id),
      [3, 1, 2],
      'the original array reference passed in via @pokemon is untouched',
    );
  });

  test('switching sort to name re-sorts the grid', async function (assert) {
    const pokemonArg = [pokemon(1, 'zubat'), pokemon(2, 'abra')];

    await render(<template><PokemonList @pokemon={{pokemonArg}} /></template>);
    await fillIn('.sort-select', 'name');

    assert.deepEqual(
      findAll('.pokemon-name').map((el) => el.textContent.trim()),
      ['abra', 'zubat'],
    );
  });

  test('search is debounced: filtering only applies after the delay', async function (assert) {
    const pokemonArg = [pokemon(1, 'bulbasaur'), pokemon(2, 'charmander')];

    await render(<template><PokemonList @pokemon={{pokemonArg}} /></template>);
    await fillIn('.search-input', 'char');

    assert.strictEqual(
      findAll('.pokemon-card').length,
      2,
      'filtering has not applied yet immediately after typing',
    );

    await waitUntil(() => findAll('.pokemon-card').length === 1, {
      timeout: 1000,
    });

    assert.dom('.pokemon-name').hasText('charmander');
  });

  test('pagination: previous is disabled on page 1, next loads the next page, previous returns without refetching', async function (assert) {
    const pokemonArg = [pokemon(1, 'bulbasaur')];
    stubFetch(this, {
      list: {
        results: [
          { name: 'pokemon-21', url: 'https://pokeapi.co/api/v2/pokemon/21/' },
        ],
      },
    });

    await render(<template><PokemonList @pokemon={{pokemonArg}} /></template>);

    const [previousButton, nextButton] = findAll('.page-button');
    assert.dom(previousButton).isDisabled();
    assert.dom('.page-indicator').hasText('Page 1 of 8');
    assert.dom('.pokemon-name').hasText('bulbasaur');

    await click(nextButton);
    await waitUntil(
      () => find('.pokemon-name')?.textContent.trim() === 'pokemon-21',
    );

    assert.dom('.page-indicator').hasText('Page 2 of 8');
    assert.dom(previousButton).isNotDisabled();

    await click(previousButton);

    assert.dom('.page-indicator').hasText('Page 1 of 8');
    assert.dom('.pokemon-name').hasText('bulbasaur');
  });
});
