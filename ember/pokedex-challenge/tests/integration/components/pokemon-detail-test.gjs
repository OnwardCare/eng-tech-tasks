import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, find, waitUntil } from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import PokemonDetail from 'pokedex-challenge/components/pokemon-detail';

function pokemonFixture(id, name) {
  return {
    id,
    name,
    height: 7,
    weight: 69,
    sprites: {
      other: {
        'official-artwork': {
          front_default: `https://example.com/${name}.png`,
        },
      },
    },
    types: [{ type: { name: 'grass' } }],
    abilities: [{ ability: { name: 'overgrow' } }],
    stats: [{ stat: { name: 'hp' }, base_stat: 45 }],
  };
}

function speciesFixture(name) {
  return {
    flavor_text_entries: [
      { language: { name: 'en' }, flavor_text: `${name} flavor text` },
    ],
    evolution_chain: { url: 'https://example.com/evolution-chain/1/' },
  };
}

const FIXTURES = {
  'https://pokeapi.co/api/v2/pokemon/1': pokemonFixture(1, 'bulbasaur'),
  'https://pokeapi.co/api/v2/pokemon-species/1': speciesFixture('bulbasaur'),
  'https://pokeapi.co/api/v2/pokemon/2': pokemonFixture(2, 'ivysaur'),
  'https://pokeapi.co/api/v2/pokemon-species/2': speciesFixture('ivysaur'),
  'https://example.com/evolution-chain/1/': {
    chain: {
      species: {
        name: 'bulbasaur',
        url: 'https://pokeapi.co/api/v2/pokemon-species/1/',
      },
      evolves_to: [],
    },
  },
};

module('Integration | Component | pokemon-detail', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.originalFetch = window.fetch;
    window.fetch = async (url) => {
      if (!(url in FIXTURES)) {
        throw new Error(`Unhandled fetch in test: ${url}`);
      }
      return { json: async () => FIXTURES[url] };
    };
  });

  hooks.afterEach(function () {
    window.fetch = this.originalFetch;
  });

  test('renders the fetched pokemon', async function (assert) {
    await render(<template><PokemonDetail @pokemonId="1" /></template>);
    await waitUntil(() => find('.detail-name'));

    assert.dom('.detail-name').containsText('bulbasaur');
    assert.dom('.flavor-text').hasText('bulbasaur flavor text');
  });

  test('refetches and re-renders when @pokemonId changes', async function (assert) {
    class State {
      @tracked pokemonId = '1';
    }
    const state = new State();

    await render(
      <template><PokemonDetail @pokemonId={{state.pokemonId}} /></template>,
    );
    await waitUntil(() => find('.detail-name'));
    assert.dom('.detail-name').containsText('bulbasaur');

    state.pokemonId = '2';

    await waitUntil(() =>
      find('.detail-name')?.textContent.includes('ivysaur'),
    );
    assert.dom('.detail-name').containsText('ivysaur');
    assert.dom('.flavor-text').hasText('ivysaur flavor text');
  });

  test('shows an error message when the fetch fails', async function (assert) {
    window.fetch = async () => {
      throw new Error('network down');
    };

    await render(<template><PokemonDetail @pokemonId="1" /></template>);
    await waitUntil(() => find('.status-message'));

    assert.dom('.status-message').hasText("Couldn't load this Pokémon.");
  });
});
