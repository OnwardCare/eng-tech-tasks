import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, find, findAll, settled } from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

class State {
  @tracked pokemonId;
}

// Fixture: Bulbasaur -> Ivysaur -> Venusaur
const BULBASAUR_SPECIES = {
  id: 1,
  name: 'bulbasaur',
  evolution_chain: { url: 'https://pokeapi.co/api/v2/evolution-chain/1/' },
};

const BULBASAUR_CHAIN = {
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

// Fixture: Eevee -> (vaporeon, jolteon, flareon)
const EEVEE_SPECIES = {
  id: 133,
  name: 'eevee',
  evolution_chain: { url: 'https://pokeapi.co/api/v2/evolution-chain/67/' },
};

const EEVEE_CHAIN = {
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
      {
        species: {
          name: 'flareon',
          url: 'https://pokeapi.co/api/v2/pokemon-species/136/',
        },
        evolves_to: [],
      },
    ],
  },
};

function stubFetch(routes) {
  const original = window.fetch;

  window.fetch = async (url) => {
    // Pick the most specific (longest) matching substring so that, e.g.,
    // "pokemon-species/1" doesn't accidentally match "pokemon-species/133".
    const match = routes
      .filter(([substring]) => url.includes(substring))
      .sort((a, b) => b[0].length - a[0].length)[0];

    if (!match) {
      throw new Error(`Unexpected fetch call in test: ${url}`);
    }

    const [, payload] = match;

    return {
      ok: true,
      json: async () => payload,
    };
  };

  return () => {
    window.fetch = original;
  };
}

function stubFetchFailure() {
  const original = window.fetch;

  window.fetch = async () => ({
    ok: false,
    json: async () => ({}),
  });

  return () => {
    window.fetch = original;
  };
}

module('Integration | Component | evolution-chain', function (hooks) {
  setupRenderingTest(hooks);

  hooks.afterEach(function () {
    if (this.restoreFetch) {
      this.restoreFetch();
      this.restoreFetch = null;
    }
  });

  test('renders the evolution line in order', async function (assert) {
    this.restoreFetch = stubFetch([
      ['pokemon-species/1', BULBASAUR_SPECIES],
      ['evolution-chain/1', BULBASAUR_CHAIN],
    ]);

    await render(<template><EvolutionChain @pokemonId={{1}} /></template>);

    const names = findAll('.evolution-stage-name').map((el) =>
      el.textContent.trim(),
    );

    assert.deepEqual(
      names,
      ['bulbasaur', 'ivysaur', 'venusaur'],
      'renders all three stages in evolutionary order',
    );
  });

  test('links each non-current stage to its own detail page', async function (assert) {
    this.restoreFetch = stubFetch([
      ['pokemon-species/1', BULBASAUR_SPECIES],
      ['evolution-chain/1', BULBASAUR_CHAIN],
    ]);

    await render(<template><EvolutionChain @pokemonId={{1}} /></template>);

    const links = findAll('.evolution-chain a.evolution-stage');
    const hrefs = links.map((link) => link.getAttribute('href'));

    assert.ok(
      hrefs.some((href) => href.endsWith('/pokemon/2')),
      'ivysaur links to /pokemon/2',
    );
    assert.ok(
      hrefs.some((href) => href.endsWith('/pokemon/3')),
      'venusaur links to /pokemon/3',
    );
  });

  test('the currently viewed pokemon is not clickable and is marked as current', async function (assert) {
    this.restoreFetch = stubFetch([
      ['pokemon-species/1', BULBASAUR_SPECIES],
      ['evolution-chain/1', BULBASAUR_CHAIN],
    ]);

    // pokemonId=1 -> bulbasaur
    await render(<template><EvolutionChain @pokemonId={{1}} /></template>);

    const current = find('.evolution-stage-current');
    assert.ok(current, 'renders an element marked as the current stage');
    assert.strictEqual(
      current.tagName,
      'DIV',
      'the current stage is not an anchor/link',
    );
    assert.dom(current).hasAttribute('aria-current', 'page');
    assert
      .dom(current)
      .hasText(/bulbasaur/, 'the current stage shows the right pokemon name');

    // 2 links (ivysaur y venusaur), no 3
    const links = findAll('.evolution-chain a.evolution-stage');
    assert.strictEqual(
      links.length,
      2,
      'only the non-current stages are rendered as links',
    );
  });

  test('renders a branching evolution chain (e.g. Eevee) showing every branch', async function (assert) {
    this.restoreFetch = stubFetch([
      ['pokemon-species/133', EEVEE_SPECIES],
      ['evolution-chain/67', EEVEE_CHAIN],
    ]);

    await render(<template><EvolutionChain @pokemonId={{133}} /></template>);

    const names = findAll('.evolution-stage-name').map((el) =>
      el.textContent.trim(),
    );

    assert.ok(names.includes('eevee'), 'renders the base pokemon');
    assert.ok(names.includes('vaporeon'), 'renders the first branch');
    assert.ok(names.includes('jolteon'), 'renders the second branch');
    assert.ok(names.includes('flareon'), 'renders the third branch');
  });

  test('shows an error message when the API request fails', async function (assert) {
    this.restoreFetch = stubFetchFailure();

    await render(<template><EvolutionChain @pokemonId={{1}} /></template>);

    assert
      .dom('.evolution-error')
      .exists('renders an error state when the fetch fails')
      .hasText(/could not load/i);
  });

  test('re-fetches the evolution chain when @pokemonId changes', async function (assert) {
    this.restoreFetch = stubFetch([
      ['pokemon-species/1', BULBASAUR_SPECIES],
      ['evolution-chain/1', BULBASAUR_CHAIN],
      ['pokemon-species/133', EEVEE_SPECIES],
      ['evolution-chain/67', EEVEE_CHAIN],
    ]);

    const state = new State();
    state.pokemonId = 1;
    this.state = state;

    await render(
      <template>
        <EvolutionChain @pokemonId={{this.state.pokemonId}} />
      </template>,
    );

    assert
      .dom('.evolution-stage-name')
      .exists({ count: 3 }, 'shows the bulbasaur line initially');

    state.pokemonId = 133;
    await settled();

    const names = findAll('.evolution-stage-name').map((el) =>
      el.textContent.trim(),
    );
    assert.ok(
      names.includes('eevee'),
      'shows the eevee line after @pokemonId changes',
    );
    assert.notOk(
      names.includes('bulbasaur'),
      'no longer shows the old bulbasaur line',
    );
  });
});
