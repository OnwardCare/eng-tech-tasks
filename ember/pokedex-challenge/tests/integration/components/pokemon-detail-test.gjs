import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, settled } from '@ember/test-helpers';
import Service from '@ember/service';
import PokemonDetail from 'pokedex-challenge/components/pokemon-detail';

module('Integration | Component | pokemon-detail', function (hooks) {
  setupRenderingTest(hooks);

  test('uses generic flavor text when species fetch fails', async function (assert) {
    this.owner.unregister('service:poke-data');
    this.owner.register(
      'service:poke-data',
      class extends Service {
        fetchPokemon() {
          return {
            id: 25,
            name: 'pikachu',
            height: 4,
            weight: 60,
            sprites: {
              front_default: 'pikachu.png',
              other: { 'official-artwork': { front_default: 'art.png' } },
            },
            types: [{ type: { name: 'electric' } }],
            abilities: [{ ability: { name: 'static' } }],
            stats: [{ stat: { name: 'hp' }, base_stat: 35 }],
          };
        }

        fetchSpecies() {
          throw new Error('Failed to fetch species "25"');
        }

        fetchEvolutionChain() {
          return {
            unavailable: true,
            message: 'No available for this Pokemon.',
          };
        }
      },
    );

    await render(<template><PokemonDetail @pokemonId={{25}} /></template>);
    await settled();

    assert.dom('.detail-name').includesText('pikachu');
    assert
      .dom('.flavor-text')
      .hasText('No description available for this Pokemon.');
  });
});
