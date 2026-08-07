import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, findAll } from '@ember/test-helpers';
import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

module('Integration | Component | evolution-chain', function (hooks) {
  setupRenderingTest(hooks);

  test('renders the evolution line in order', async function (assert) {
    const stages = [
      { pokemons: [{ id: 1, name: 'bulbasaur' }], isLast: false },
      { pokemons: [{ id: 2, name: 'ivysaur' }], isLast: false },
      { pokemons: [{ id: 3, name: 'venusaur' }], isLast: true },
    ];

    await render(<template><EvolutionChain @stages={{stages}} /></template>);

    const names = findAll('.evolution-stage-link').map((el) =>
      el.textContent.trim(),
    );
    assert.deepEqual(names, ['bulbasaur', 'ivysaur', 'venusaur']);
  });

  test('renders a placeholder when there are no stages', async function (assert) {
    await render(<template><EvolutionChain @stages={{null}} /></template>);

    assert
      .dom('.evolution-placeholder')
      .hasText('No evolution data available.');
  });
});
