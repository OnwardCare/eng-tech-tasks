import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, findAll, waitUntil } from '@ember/test-helpers';
import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

module('Integration | Component | evolution-chain', function (hooks) {
  setupRenderingTest(hooks);

  test('renders the evolution line in order', async function (assert) {
    await render(<template><EvolutionChain @pokemonId={{1}} /></template>);
    await waitUntil(() => findAll('.evolution-stage-link').length > 0);

    const names = findAll('.evolution-stage-link').map((el) =>
      el.textContent.trim(),
    );
    assert.deepEqual(names, ['bulbasaur', 'ivysaur', 'venusaur']);
  });
});
