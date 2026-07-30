import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, rerender, findAll, waitUntil } from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

module('Integration | Component | evolution-chain', function (hooks) {
  setupRenderingTest(hooks);

  test('renders the evolution line in order', async function (assert) {
    await render(<template><EvolutionChain @pokemonId={{1}} /></template>);
    await waitUntil(() => findAll('.evolution-link').length > 0);

    const names = findAll('.evolution-link').map((el) => el.textContent.trim());
    assert.deepEqual(names, ['bulbasaur', 'ivysaur', 'venusaur']);
  });

  test('reloads when @pokemonId changes on an already-rendered instance', async function (assert) {
    class State {
      @tracked pokemonId = 1;
    }
    const state = new State();

    await render(
      <template><EvolutionChain @pokemonId={{state.pokemonId}} /></template>,
    );
    await waitUntil(() => findAll('.evolution-link').length > 0);
    assert.deepEqual(
      findAll('.evolution-link').map((el) => el.textContent.trim()),
      ['bulbasaur', 'ivysaur', 'venusaur'],
      'initial render shows the bulbasaur chain',
    );

    state.pokemonId = 4; // charmander
    await rerender();
    await waitUntil(
      () => findAll('.evolution-link')[0]?.textContent.trim() === 'charmander',
      { timeout: 5000 },
    );
    assert.deepEqual(
      findAll('.evolution-link').map((el) => el.textContent.trim()),
      ['charmander', 'charmeleon', 'charizard'],
      'after @pokemonId changes, shows the charmander chain',
    );
  });
});
