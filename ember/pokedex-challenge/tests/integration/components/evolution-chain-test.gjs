import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, settled } from '@ember/test-helpers';
import Service from '@ember/service';
import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

module('Integration | Component | evolution-chain', function (hooks) {
  setupRenderingTest(hooks);

  test('shows unavailable message when evolution chain is missing', async function (assert) {
    this.owner.unregister('service:poke-data');
    this.owner.register(
      'service:poke-data',
      class extends Service {
        fetchEvolutionChain() {
          return {
            unavailable: true,
            message: 'No available for this Pokemon.',
          };
        }
      },
    );

    await render(<template><EvolutionChain @pokemonId={{10084}} /></template>);
    await settled();

    assert.dom('.evolution-error').hasText('No available for this Pokemon.');
  });

  test('renders evolution stages in order', async function (assert) {
    this.owner.unregister('service:poke-data');
    this.owner.register(
      'service:poke-data',
      class extends Service {
        fetchEvolutionChain() {
          return {
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
        }

        fetchPokemon(id) {
          const names = { 1: 'bulbasaur', 2: 'ivysaur', 3: 'venusaur' };
          return {
            id: Number(id),
            name: names[id],
            sprites: { front_default: `${names[id]}.png` },
            types: [{ type: { name: 'grass' } }],
          };
        }
      },
    );

    await render(<template><EvolutionChain @pokemonId={{1}} /></template>);
    await settled();

    assert.dom('.pokemon-name').exists({ count: 3 });
    assert.dom('.pokemon-name').hasText('bulbasaur');
    assert
      .dom('.evolution-stage:nth-child(1) .pokemon-card')
      .hasClass('is-highlighted');
  });
});
