import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, waitFor } from '@ember/test-helpers';
import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

// Fake chain URL returned by the route model hook
const CHAIN_URL = 'https://pokeapi.co/api/v2/evolution-chain/1/';

// Mock the PokéAPI evolution chain response for Bulbasaur → Ivysaur → Venusaur
const MOCK_CHAIN = {
  chain: {
    species: { name: 'bulbasaur', url: 'https://pokeapi.co/api/v2/pokemon-species/1/' },
    evolves_to: [{
      species: { name: 'ivysaur', url: 'https://pokeapi.co/api/v2/pokemon-species/2/' },
      evolves_to: [{
        species: { name: 'venusaur', url: 'https://pokeapi.co/api/v2/pokemon-species/3/' },
        evolves_to: [],
      }],
    }],
  },
};

module('Integration | Component | evolution-chain', function (hooks) {
  setupRenderingTest(hooks);

  let originalFetch;

  hooks.beforeEach(function () {
    originalFetch = window.fetch;
    // Intercept fetch calls to avoid real network requests in tests
    window.fetch = async (url) => {
      if (url === CHAIN_URL) {
        return { json: async () => MOCK_CHAIN };
      }
      throw new Error(`Unexpected fetch: ${url}`);
    };
  });

  hooks.afterEach(function () {
    window.fetch = originalFetch;
  });

  test('renders the evolution line in order', async function (assert) {
    await render(
      <template><EvolutionChain @evolutionChainUrl={{CHAIN_URL}} /></template>,
    );

    // Wait for the async load to finish
    await waitFor('.evolution-chain');

    const stages = document.querySelectorAll('.evolution-stage a');
    assert.strictEqual(stages.length, 3, 'three stages render');
    assert.dom(stages[0]).hasText('bulbasaur');
    assert.dom(stages[1]).hasText('ivysaur');
    assert.dom(stages[2]).hasText('venusaur');
  });

  test('shows a loading state before data arrives', async function (assert) {
    // Use a promise that never resolves to keep the component in loading state
    window.fetch = () => new Promise(() => {});

    await render(
      <template><EvolutionChain @evolutionChainUrl={{CHAIN_URL}} /></template>,
    );

    assert.dom('.evolution-loading').exists();
  });

  test('shows an error when fetch fails', async function (assert) {
    window.fetch = async () => { throw new Error('network error'); };

    await render(
      <template><EvolutionChain @evolutionChainUrl={{CHAIN_URL}} /></template>,
    );

    await waitFor('.evolution-error');
    assert.dom('.evolution-error').exists();
  });
});
