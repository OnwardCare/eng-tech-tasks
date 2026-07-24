import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, settled, findAll } from '@ember/test-helpers';
import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';
import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

function stage(id, name) {
  return { id, name, sprite: `/${name}.png` };
}

const LINES = [
  [[stage(1, 'bulbasaur'), stage(2, 'ivysaur'), stage(3, 'venusaur')]],
  [[stage(83, 'farfetchd')]],
  [
    [stage(133, 'eevee'), stage(134, 'vaporeon')],
    [stage(133, 'eevee'), stage(135, 'jolteon')],
    [stage(133, 'eevee'), stage(136, 'flareon')],
  ],
];

class StubPokeData extends Service {
  requestedIds = [];

  fetchEvolutionPaths(idOrName) {
    this.requestedIds.push(idOrName);

    const paths = LINES.find((line) =>
      line.flat().some((pokemon) => pokemon.id === idOrName),
    );

    return paths
      ? Promise.resolve(paths)
      : Promise.reject(new Error(`no line for ${idOrName}`));
  }
}

function renderedPaths() {
  return findAll('.evolution-path').map((path) =>
    [...path.querySelectorAll('.evolution-link')].map((link) =>
      link.textContent.trim(),
    ),
  );
}

module('Integration | Component | evolution-chain', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.owner.register('service:poke-data', StubPokeData);
    this.owner.setupRouter();
  });

  test('renders the evolution line in order', async function (assert) {
    await render(<template><EvolutionChain @pokemonId={{1}} /></template>);

    assert.deepEqual(renderedPaths(), [['bulbasaur', 'ivysaur', 'venusaur']]);
  });

  test('each stage links to its own detail page', async function (assert) {
    await render(<template><EvolutionChain @pokemonId={{1}} /></template>);

    assert.deepEqual(
      findAll('.evolution-link').map((el) => el.getAttribute('href')),
      ['/pokemon/1', '/pokemon/2', '/pokemon/3'],
    );
  });

  test('marks the pokemon being viewed as current', async function (assert) {
    await render(<template><EvolutionChain @pokemonId={{2}} /></template>);

    assert.dom('.evolution-link.is-current').hasText('ivysaur');
    assert
      .dom('.evolution-link.is-current')
      .hasAttribute('aria-current', 'page');
    assert.strictEqual(findAll('.evolution-link.is-current').length, 1);
  });

  test('a branch point shows one row per evolution', async function (assert) {
    await render(<template><EvolutionChain @pokemonId={{133}} /></template>);

    assert.deepEqual(renderedPaths(), [
      ['eevee', 'vaporeon'],
      ['eevee', 'jolteon'],
      ['eevee', 'flareon'],
    ]);
  });

  test('a branch only shows the row it belongs to', async function (assert) {
    await render(<template><EvolutionChain @pokemonId={{135}} /></template>);

    assert.deepEqual(renderedPaths(), [['eevee', 'jolteon']]);
    assert.dom('.evolution-link.is-current').hasText('jolteon');
  });

  test('says so when a pokemon does not evolve', async function (assert) {
    await render(<template><EvolutionChain @pokemonId={{83}} /></template>);

    assert.dom('.evolution-status').hasText('This Pokémon does not evolve.');
    assert.deepEqual(renderedPaths(), [['farfetchd']]);
  });

  test('shows an error message when the chain cannot be loaded', async function (assert) {
    await render(<template><EvolutionChain @pokemonId={{999}} /></template>);

    assert.dom('.evolution-error').exists();
    assert.strictEqual(findAll('.evolution-path').length, 0);
  });

  test('reloads when the pokemon changes', async function (assert) {
    const state = new (class {
      @tracked pokemonId = 1;
    })();

    await render(
      <template><EvolutionChain @pokemonId={{state.pokemonId}} /></template>,
    );
    assert.deepEqual(renderedPaths(), [['bulbasaur', 'ivysaur', 'venusaur']]);

    state.pokemonId = 134;
    await settled();

    assert.deepEqual(renderedPaths(), [['eevee', 'vaporeon']]);
    assert.deepEqual(
      this.owner.lookup('service:poke-data').requestedIds,
      [1, 134],
      'one request per pokemon',
    );
  });
});
