import { module, skip } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render } from '@ember/test-helpers';
import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

module('Integration | Component | evolution-chain', function (hooks) {
  setupRenderingTest(hooks);

  // TODO: finish evolution chain test once the component is implemented
  skip('renders the evolution line in order', async function (assert) {
    await render(<template><EvolutionChain @pokemonId={{1}} /></template>);

    assert.ok(true);
  });
});
