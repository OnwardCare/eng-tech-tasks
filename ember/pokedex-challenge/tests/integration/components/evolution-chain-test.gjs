import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, click, waitFor } from '@ember/test-helpers';
import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

const bulbasaurSpecies = {
  id: 1,
  name: 'bulbasaur',
  evolution_chain: {
    url: 'https://pokeapi.co/api/v2/evolution-chain/1/',
  },
};

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

const dittoSpecies = {
  id: 132,
  name: 'ditto',
  evolution_chain: null,
};

module('Integration | Component | evolution-chain', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.originalFetch = window.fetch;

    this.mockSuccess = (responses) => {
      window.fetch = async (url) => {
        // Normalize URLs (strip trailing slash for matching)
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

    this.mockFailure = () => {
      window.fetch = async () => {
        throw new Error('Network error');
      };
    };
  });

  hooks.afterEach(function () {
    window.fetch = this.originalFetch;
  });

  test('renders evolution stages in order for a multi-stage Pokémon', async function (assert) {
    this.mockSuccess({
      'https://pokeapi.co/api/v2/pokemon-species/1': bulbasaurSpecies,
      'https://pokeapi.co/api/v2/evolution-chain/1/': bulbasaurChain,
    });

    await render(<template><EvolutionChain @pokemonId={{1}} /></template>);
    await waitFor('.evolution-line');

    const links = [...document.querySelectorAll('.evolution-link')].map((el) =>
      el.textContent.trim(),
    );
    assert.deepEqual(
      links,
      ['bulbasaur', 'ivysaur', 'venusaur'],
      'renders all stages in order',
    );
    assert.dom('.evolution-arrow').exists({ count: 2 });
  });

  test('evolution links point to the correct pokemon route', async function (assert) {
    this.mockSuccess({
      'https://pokeapi.co/api/v2/pokemon-species/1': bulbasaurSpecies,
      'https://pokeapi.co/api/v2/evolution-chain/1/': bulbasaurChain,
    });

    await render(<template><EvolutionChain @pokemonId={{1}} /></template>);
    await waitFor('.evolution-link');

    const hrefs = [...document.querySelectorAll('.evolution-link')].map((el) =>
      el.getAttribute('href'),
    );
    assert.strictEqual(hrefs.length, 3);
    assert.true(hrefs[0].includes('/pokemon/1'), 'first link -> /pokemon/1');
    assert.true(hrefs[1].includes('/pokemon/2'), 'second link -> /pokemon/2');
    assert.true(hrefs[2].includes('/pokemon/3'), 'third link -> /pokemon/3');
  });

  test('shows loading state while fetching', async function (assert) {
    let resolveFetch;
    window.fetch = () =>
      new Promise((resolve) => {
        resolveFetch = resolve;
      });

    const renderPromise = render(
      <template><EvolutionChain @pokemonId={{1}} /></template>,
    );

    await waitFor('.evolution-loading');
    assert.dom('.evolution-loading').exists('loading indicator is visible');
    assert.dom('.spinner').exists('spinner is visible');

    // Resolve pending fetch to allow cleanup
    resolveFetch({ ok: false, status: 500, json: async () => ({}) });
    await renderPromise;
  });

  test('shows error message with retry button when fetch fails', async function (assert) {
    this.mockFailure();

    await render(<template><EvolutionChain @pokemonId={{1}} /></template>);
    await waitFor('.evolution-error');

    assert
      .dom('.evolution-error')
      .includesText('Failed to load evolution chain');
    assert.dom('.evolution-retry').exists('retry button is visible');
  });

  test('retry button refetches and shows chain on success', async function (assert) {
    this.mockFailure();

    await render(<template><EvolutionChain @pokemonId={{1}} /></template>);
    await waitFor('.evolution-error');
    assert.dom('.evolution-error').exists('shows error initially');

    // Update mock to succeed for retry
    this.mockSuccess({
      'https://pokeapi.co/api/v2/pokemon-species/1': bulbasaurSpecies,
      'https://pokeapi.co/api/v2/evolution-chain/1/': bulbasaurChain,
    });

    await click('.evolution-retry');
    await waitFor('.evolution-line');

    assert.dom('.evolution-error').doesNotExist('error cleared after retry');
    assert.dom('.evolution-link').exists({ count: 3 });
  });

  test('shows "does not evolve" message for single-stage Pokémon', async function (assert) {
    this.mockSuccess({
      'https://pokeapi.co/api/v2/pokemon-species/132': dittoSpecies,
    });

    await render(<template><EvolutionChain @pokemonId={{132}} /></template>);
    await waitFor('.evolution-none');

    assert.dom('.evolution-none').hasText('This Pokémon does not evolve.');
    assert.dom('.evolution-line').doesNotExist();
  });
});
