import { module, test } from 'qunit';
import { setupTest } from 'pokedex-challenge/tests/helpers';

module('Unit | Service | poke-data', function (hooks) {
  setupTest(hooks);

  hooks.beforeEach(function () {
    this.originalFetch = window.fetch;
  });

  hooks.afterEach(function () {
    window.fetch = this.originalFetch;
  });

  test('fetchEvolutionChain returns unavailable when species is missing', async function (assert) {
    window.fetch = async () => new Response(null, { status: 404 });

    const pokeData = this.owner.lookup('service:poke-data');
    const result = await pokeData.fetchEvolutionChain(10084);

    assert.true(result.unavailable);
    assert.strictEqual(result.message, 'No available for this Pokemon.');
  });

  test('fetchPokemon throws when request fails', async function (assert) {
    window.fetch = async () => new Response(null, { status: 404 });

    const pokeData = this.owner.lookup('service:poke-data');

    await assert.rejects(
      pokeData.fetchPokemon('missing'),
      /Failed to fetch pokemon "missing"/,
    );
  });

  test('searchPokemons returns matching name cards', async function (assert) {
    window.fetch = async (url) => {
      const href = String(url);

      if (href.includes('/pokemon?')) {
        return new Response(
          JSON.stringify({
            results: [
              { name: 'pikachu', url: 'https://pokeapi.co/api/v2/pokemon/25/' },
              {
                name: 'raichu',
                url: 'https://pokeapi.co/api/v2/pokemon/26/',
              },
              {
                name: 'bulbasaur',
                url: 'https://pokeapi.co/api/v2/pokemon/1/',
              },
            ],
          }),
          { status: 200 },
        );
      }

      if (href.endsWith('/pokemon/pikachu')) {
        return new Response(
          JSON.stringify({
            id: 25,
            name: 'pikachu',
            sprites: { front_default: 'pikachu.png' },
            types: [{ type: { name: 'electric' } }],
          }),
          { status: 200 },
        );
      }

      return new Response(null, { status: 404 });
    };

    const pokeData = this.owner.lookup('service:poke-data');
    const results = await pokeData.searchPokemons('pika');

    assert.strictEqual(results.length, 1);
    assert.strictEqual(results[0].name, 'pikachu');
    assert.strictEqual(results[0].id, 25);
  });
});
