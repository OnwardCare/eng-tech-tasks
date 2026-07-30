import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, waitUntil, settled } from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import PokemonDetail from 'pokedex-challenge/components/pokemon-detail';

function pokemonPayload({ id, name, hp }) {
  return {
    id,
    name,
    height: 7,
    weight: 69,
    sprites: {
      other: { 'official-artwork': { front_default: `${name}.png` } },
    },
    types: [{ type: { name: 'grass' } }],
    abilities: [{ ability: { name: 'overgrow' } }],
    stats: [{ stat: { name: 'hp' }, base_stat: hp }],
  };
}

function speciesPayload({ id, name, flavorText }) {
  return {
    id,
    name,
    flavor_text_entries: [
      { language: { name: 'en' }, flavor_text: flavorText },
    ],
    evolution_chain: {
      url: 'https://pokeapi.co/api/v2/evolution-chain/1/',
    },
  };
}

const bulbasaurChain = {
  id: 1,
  chain: {
    species: {
      name: 'bulbasaur',
      url: 'https://pokeapi.co/api/v2/pokemon-species/1/',
    },
    evolves_to: [
      {
        species: {
          name: 'ivysaur',
          url: 'https://pokeapi.co/api/v2/pokemon-species/2/',
        },
        evolves_to: [],
      },
    ],
  },
};

module('Integration | Component | pokemon-detail', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.originalFetch = window.fetch;

    this.mockResponses = (responses) => {
      window.fetch = async (url) => {
        const normalized = url.endsWith('/') ? url.slice(0, -1) : url;
        for (const [key, value] of Object.entries(responses)) {
          const normalizedKey = key.endsWith('/') ? key.slice(0, -1) : key;
          if (normalized === normalizedKey || url === key) {
            return { ok: true, json: async () => value };
          }
        }
        throw new Error(`No mock for ${url}`);
      };
    };
  });

  hooks.afterEach(function () {
    window.fetch = this.originalFetch;
  });

  test('renders pokemon data for the given pokemonId', async function (assert) {
    this.mockResponses({
      'https://pokeapi.co/api/v2/pokemon/1': pokemonPayload({
        id: 1,
        name: 'bulbasaur',
        hp: 45,
      }),
      'https://pokeapi.co/api/v2/pokemon-species/1': speciesPayload({
        id: 1,
        name: 'bulbasaur',
        flavorText: 'A strange seed was planted on its back at birth.',
      }),
      'https://pokeapi.co/api/v2/evolution-chain/1/': bulbasaurChain,
      'https://pokeapi.co/api/v2/pokemon-species/2': speciesPayload({
        id: 2,
        name: 'ivysaur',
        flavorText: 'Ivysaur flavor text.',
      }),
    });

    await render(<template><PokemonDetail @pokemonId={{1}} /></template>);
    await waitUntil(() => document.querySelector('.detail-name'));

    assert.dom('.detail-name').containsText('bulbasaur');
    assert.dom('.detail-id').hasText('#1');
    assert
      .dom('.flavor-text')
      .hasText('A strange seed was planted on its back at birth.');
  });

  test('reloads all detail content when @pokemonId changes (STORY-04 regression)', async function (assert) {
    this.mockResponses({
      'https://pokeapi.co/api/v2/pokemon/1': pokemonPayload({
        id: 1,
        name: 'bulbasaur',
        hp: 45,
      }),
      'https://pokeapi.co/api/v2/pokemon/2': pokemonPayload({
        id: 2,
        name: 'ivysaur',
        hp: 60,
      }),
      'https://pokeapi.co/api/v2/pokemon-species/1': speciesPayload({
        id: 1,
        name: 'bulbasaur',
        flavorText: 'Bulbasaur flavor text.',
      }),
      'https://pokeapi.co/api/v2/pokemon-species/2': speciesPayload({
        id: 2,
        name: 'ivysaur',
        flavorText: 'Ivysaur flavor text.',
      }),
      'https://pokeapi.co/api/v2/evolution-chain/1/': bulbasaurChain,
    });

    class State {
      @tracked pokemonId = 1;
    }
    const state = new State();

    await render(
      <template><PokemonDetail @pokemonId={{state.pokemonId}} /></template>,
    );
    await waitUntil(() => document.querySelector('.detail-name'));

    assert.dom('.detail-name').containsText('bulbasaur');
    assert.dom('.flavor-text').hasText('Bulbasaur flavor text.');
    assert.dom('.stat-value').hasText('45');

    // Simulate navigating from /pokemon/1 to /pokemon/2 via an evolution
    // link, which reuses the same PokemonDetail component instance rather
    // than destroying and recreating it.
    state.pokemonId = 2;
    await settled();
    await waitUntil(() =>
      document.querySelector('.detail-name')?.textContent.includes('ivysaur'),
    );

    assert.dom('.detail-name').containsText('ivysaur');
    assert.dom('.detail-id').hasText('#2');
    assert.dom('.flavor-text').hasText('Ivysaur flavor text.');
    assert.dom('.stat-value').hasText('60');
  });
});
