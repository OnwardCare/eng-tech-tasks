import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, findAll } from '@ember/test-helpers';
import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

function jsonResponse(body) {
  return {
    ok: true,
    json: async () => body,
  };
}

const SPECIES = {
  evolution_chain: { url: 'https://pokeapi.co/api/v2/evolution-chain/1/' },
};

const LINEAR_CHAIN = {
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
        evolves_to: [
          {
            species: {
              name: 'venusaur',
              url: 'https://pokeapi.co/api/v2/pokemon-species/3/',
            },
            evolves_to: [],
          },
        ],
      },
    ],
  },
};

const BRANCHING_CHAIN = {
  chain: {
    species: {
      name: 'eevee',
      url: 'https://pokeapi.co/api/v2/pokemon-species/133/',
    },
    evolves_to: [
      {
        species: {
          name: 'vaporeon',
          url: 'https://pokeapi.co/api/v2/pokemon-species/134/',
        },
        evolves_to: [],
      },
      {
        species: {
          name: 'jolteon',
          url: 'https://pokeapi.co/api/v2/pokemon-species/135/',
        },
        evolves_to: [],
      },
    ],
  },
};

function stubFetch(chain) {
  const originalFetch = globalThis.fetch;
  globalThis.fetch = async (url) => {
    if (url.includes('pokemon-species')) {
      return jsonResponse(SPECIES);
    }
    if (url.includes('evolution-chain')) {
      return jsonResponse(chain);
    }
    // per-pokemon sprite lookup
    return jsonResponse({ sprites: { front_default: `${url}.png` } });
  };
  return () => {
    globalThis.fetch = originalFetch;
  };
}

module('Integration | Component | evolution-chain', function (hooks) {
  setupRenderingTest(hooks);

  test('renders the evolution line in order', async function (assert) {
    const restore = stubFetch(LINEAR_CHAIN);
    try {
      await render(<template><EvolutionChain @pokemonId={{1}} /></template>);

      const names = findAll('.evolution-name').map((el) =>
        el.textContent.trim(),
      );
      assert.deepEqual(names, ['bulbasaur', 'ivysaur', 'venusaur']);
      assert.strictEqual(findAll('.evolution-link').length, 3);
    } finally {
      restore();
    }
  });

  test('renders branching chains as multiple lines', async function (assert) {
    const restore = stubFetch(BRANCHING_CHAIN);
    try {
      await render(<template><EvolutionChain @pokemonId={{133}} /></template>);

      const names = findAll('.evolution-name').map((el) =>
        el.textContent.trim(),
      );
      assert.deepEqual(names, ['eevee', 'vaporeon', 'jolteon']);
    } finally {
      restore();
    }
  });

  test('shows an error state when the chain fails to load', async function (assert) {
    const originalFetch = globalThis.fetch;
    globalThis.fetch = async () => ({ ok: false, json: async () => ({}) });

    try {
      await render(<template><EvolutionChain @pokemonId={{1}} /></template>);

      assert.dom('.evolution-error').exists();
    } finally {
      globalThis.fetch = originalFetch;
    }
  });
});
