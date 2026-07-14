import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render } from '@ember/test-helpers';
import { find, findAll } from '@ember/test-helpers';
import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

module('Integration | Component | evolution-chain', function (hooks) {
  setupRenderingTest(hooks);

  test('renders a 3-stage linear chain with arrows between stages', async function (assert) {
    const chain = [
      { id: 1, name: 'bulbasaur', separator: null },
      { id: 2, name: 'ivysaur', separator: '→' },
      { id: 3, name: 'venusaur', separator: '→' },
    ];

    await render(<template><EvolutionChain @chain={{chain}} /></template>);

    const stages = findAll('.evo-stage');
    assert.strictEqual(stages.length, 3, 'renders 3 stages');
    assert.strictEqual(stages[0].textContent.trim(), 'bulbasaur');
    assert.strictEqual(stages[1].textContent.trim(), 'ivysaur');
    assert.strictEqual(stages[2].textContent.trim(), 'venusaur');

    const separators = findAll('.evo-sep');
    assert.strictEqual(separators.length, 2, 'renders 2 arrows');
    assert.strictEqual(separators[0].textContent.trim(), '→');
  });

  test('renders a single-stage chain with no arrows', async function (assert) {
    const chain = [{ id: 132, name: 'ditto', separator: null }];

    await render(<template><EvolutionChain @chain={{chain}} /></template>);

    assert.strictEqual(findAll('.evo-stage').length, 1, 'renders 1 stage');
    assert.strictEqual(findAll('.evo-sep').length, 0, 'renders no arrows');
  });

  test('renders nothing for an empty chain', async function (assert) {
    const chain = [];

    await render(<template><EvolutionChain @chain={{chain}} /></template>);

    assert.strictEqual(find('.evolution-chain'), null, 'renders nothing');
  });
});
