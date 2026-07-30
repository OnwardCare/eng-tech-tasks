import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, fillIn, settled, waitUntil } from '@ember/test-helpers';
import Service from '@ember/service';
import PokemonList from 'pokedex-challenge/components/pokemon-list';

const PAGE = [
  {
    id: 1,
    name: 'bulbasaur',
    sprite: 'bulbasaur.png',
    types: ['grass'],
  },
];

module('Integration | Component | pokemon-list', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    const listState = this.owner.lookup('service:list-state');
    listState.offset = 0;
    listState.searchTerm = '';
  });

  test('does not search until at least 3 letters are typed', async function (assert) {
    let searched = false;

    this.owner.unregister('service:poke-data');
    this.owner.register(
      'service:poke-data',
      class extends Service {
        searchPokemons() {
          searched = true;
          return [];
        }

        fetchPokemon() {
          return Promise.reject(new Error('skip featured'));
        }
      },
    );

    await render(<template><PokemonList @pokemon={{PAGE}} /></template>);
    await fillIn('.search-input', 'pi');
    await settled();
    await new Promise((resolve) => setTimeout(resolve, 350));

    assert.false(searched, 'search is not triggered under 3 letters');
    assert.dom('.pokemon-name').hasText('bulbasaur');
  });

  test('searches after 3 letters and shows results', async function (assert) {
    this.owner.unregister('service:poke-data');
    this.owner.register(
      'service:poke-data',
      class extends Service {
        searchPokemons() {
          return [
            {
              id: 25,
              name: 'pikachu',
              sprite: 'pikachu.png',
              types: ['electric'],
            },
          ];
        }

        fetchPokemon() {
          return Promise.reject(new Error('skip featured'));
        }
      },
    );

    await render(<template><PokemonList @pokemon={{PAGE}} /></template>);
    await fillIn('.search-input', 'pika');

    await waitUntil(
      () =>
        document
          .querySelector('.pokemon-name')
          ?.textContent.includes('pikachu'),
      { timeout: 2000 },
    );

    assert.dom('.pokemon-name').hasText('pikachu');
    assert.dom('.pagination').doesNotExist();
  });
});
