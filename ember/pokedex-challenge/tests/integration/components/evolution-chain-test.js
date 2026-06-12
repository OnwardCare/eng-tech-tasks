import { module, skip } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { hbs } from 'ember-cli-htmlbars';

module('Integration | Component | evolution-chain', function (hooks) {
  setupRenderingTest(hooks);

  // TODO: finish evolution chain test once the component is implemented
  skip('renders the evolution line in order', async function (assert) {
    await render(hbs`<EvolutionChain @pokemonId={{1}} />`);

    assert.ok(true);
  });
});
