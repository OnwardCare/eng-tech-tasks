import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, rerender, find, waitUntil } from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import PokemonDetail from 'pokedex-challenge/components/pokemon-detail';

module('Integration | Component | pokemon-detail', function (hooks) {
  setupRenderingTest(hooks);

  test('reloads when @pokemonId changes on an already-rendered instance', async function (assert) {
    class State {
      @tracked pokemonId = 1;
    }
    const state = new State();

    await render(
      <template><PokemonDetail @pokemonId={{state.pokemonId}} /></template>,
    );
    await waitUntil(() => find('.detail-artwork'));
    assert.dom('.detail-artwork').hasAttribute('alt', 'bulbasaur');

    state.pokemonId = 4; // charmander
    await rerender();
    await waitUntil(() => find('.detail-artwork')?.alt === 'charmander', {
      timeout: 5000,
    });
    assert.dom('.detail-artwork').hasAttribute('alt', 'charmander');
    assert
      .dom('.evolution-link')
      .exists('the evolution chain reloads along with the rest of the page');
  });
});
