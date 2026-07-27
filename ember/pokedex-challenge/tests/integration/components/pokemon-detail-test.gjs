import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, find } from '@ember/test-helpers';
import PokemonDetail from 'pokedex-challenge/components/pokemon-detail';

function jsonResponse(body, ok = true) {
  return { ok, json: async () => body };
}

const BULBASAUR = {
  id: 1,
  name: 'bulbasaur',
  height: 7,
  weight: 69,
  sprites: { other: { 'official-artwork': { front_default: 'bulba.png' } } },
  types: [{ type: { name: 'grass' } }],
  abilities: [{ ability: { name: 'overgrow' } }],
  stats: [{ stat: { name: 'hp' }, base_stat: 45 }],
};

const BULBASAUR_SPECIES = {
  evolution_chain: { url: 'https://pokeapi.co/api/v2/evolution-chain/1/' },
  flavor_text_entries: [
    { language: { name: 'en' }, flavor_text: 'A strange seed\nwas planted.' },
  ],
};

const LINEAR_CHAIN = {
  chain: {
    species: {
      name: 'bulbasaur',
      url: 'https://pokeapi.co/api/v2/pokemon-species/1/',
    },
    evolves_to: [],
  },
};

module('Integration | Component | pokemon-detail', function (hooks) {
  setupRenderingTest(hooks);

  test('renders pokemon data once loaded', async function (assert) {
    const originalFetch = globalThis.fetch;
    globalThis.fetch = async (url) => {
      if (url.includes('pokemon-species')) {
        return jsonResponse(BULBASAUR_SPECIES);
      }
      if (url.includes('evolution-chain')) {
        return jsonResponse(LINEAR_CHAIN);
      }
      if (url.includes('/pokemon/1')) {
        return jsonResponse(BULBASAUR);
      }
      return jsonResponse({ sprites: { front_default: 'sprite.png' } });
    };

    try {
      await render(<template><PokemonDetail @pokemonId={{1}} /></template>);

      assert.dom('.detail-name').containsText('bulbasaur');
      assert.dom('.flavor-text').hasText('A strange seed was planted.');
      assert.dom('.detail-loading').doesNotExist();
    } finally {
      globalThis.fetch = originalFetch;
    }
  });

  test('shows an error state when the pokemon cannot be loaded', async function (assert) {
    const originalFetch = globalThis.fetch;
    globalThis.fetch = async () => jsonResponse({}, false);

    try {
      await render(<template><PokemonDetail @pokemonId={{99999}} /></template>);

      assert.dom('.detail-error').exists();
      assert.notOk(find('.detail-name'));
    } finally {
      globalThis.fetch = originalFetch;
    }
  });
});
