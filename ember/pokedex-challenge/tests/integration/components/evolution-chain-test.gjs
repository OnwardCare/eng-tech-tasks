import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, findAll } from '@ember/test-helpers';
import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

const LINEAR = [
  [{ id: 1, name: 'bulbasaur', sprite: '/sprites/1.png' }],
  [{ id: 2, name: 'ivysaur', sprite: '/sprites/2.png' }],
  [{ id: 3, name: 'venusaur', sprite: '/sprites/3.png' }],
];

const BRANCHING = [
  [{ id: 133, name: 'eevee', sprite: '/sprites/133.png' }],
  [
    { id: 134, name: 'vaporeon', sprite: '/sprites/134.png' },
    { id: 135, name: 'jolteon', sprite: '/sprites/135.png' },
    { id: 196, name: 'espeon', sprite: null },
  ],
];

module('Integration | Component | evolution-chain', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.owner.setupRouter();
  });

  test('renders the evolution line in order', async function (assert) {
    await render(
      <template>
        <EvolutionChain @stages={{LINEAR}} @currentId={{1}} />
      </template>,
    );

    assert.deepEqual(
      findAll('.evolution-link').map((el) => el.textContent.trim()),
      ['bulbasaur', 'ivysaur', 'venusaur'],
    );
    assert.dom('.evolution-link').hasAttribute('href', '/pokemon/1');
  });

  test('marks the pokemon being viewed as current', async function (assert) {
    await render(
      <template>
        <EvolutionChain @stages={{LINEAR}} @currentId={{2}} />
      </template>,
    );

    assert.dom('.evolution-link.is-current').hasText('ivysaur');
    assert.strictEqual(findAll('.evolution-link.is-current').length, 1);
  });

  test('keeps every branch at the same stage', async function (assert) {
    await render(
      <template>
        <EvolutionChain @stages={{BRANCHING}} @currentId={{133}} />
      </template>,
    );

    assert.strictEqual(findAll('.evolution-stage').length, 2);
    assert.deepEqual(
      findAll('.evolution-stage:last-child .evolution-branches > li').map(
        (el) => el.textContent.trim(),
      ),
      ['vaporeon', 'jolteon', 'espeon'],
    );
  });

  test('a pokemon with no evolutions gets a message instead', async function (assert) {
    const none = [];

    await render(
      <template>
        <EvolutionChain @stages={{none}} @currentId={{132}} />
      </template>,
    );

    assert.dom('.empty-state').hasText('This Pokémon does not evolve.');
    assert.dom('.evolution-chain').doesNotExist();
  });
});
