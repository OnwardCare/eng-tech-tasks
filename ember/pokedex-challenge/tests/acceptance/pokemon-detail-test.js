import { module, test } from 'qunit';
import { visit, click, currentURL, findAll } from '@ember/test-helpers';
import { setupApplicationTest } from 'pokedex-challenge/tests/helpers';

function renderedPaths() {
  return findAll('.evolution-path').map((path) =>
    [...path.querySelectorAll('.evolution-link')].map((link) =>
      link.textContent.trim(),
    ),
  );
}

module('Acceptance | pokemon detail', function (hooks) {
  setupApplicationTest(hooks);

  test('the detail page shows the evolution line and each stage is navigable', async function (assert) {
    await visit('/pokemon/1');

    assert.deepEqual(
      renderedPaths(),
      [['bulbasaur', 'ivysaur', 'venusaur']],
      'the line renders in evolution order',
    );
    assert.dom('.evolution-link.is-current').hasText('bulbasaur');

    await click('.evolution-link[href="/pokemon/3"]');

    assert.strictEqual(currentURL(), '/pokemon/3');
    assert.dom('.detail-name').includesText('venusaur');
    assert.deepEqual(
      renderedPaths(),
      [['bulbasaur', 'ivysaur', 'venusaur']],
      'the line still renders after navigating within it',
    );
    assert.dom('.evolution-link.is-current').hasText('venusaur');
  });

  test('a branch point lists every evolution as its own line', async function (assert) {
    await visit('/pokemon/133');

    const paths = renderedPaths();
    assert.ok(paths.length > 1, 'eevee has a row per evolution');
    assert.ok(
      paths.every((path) => path[0] === 'eevee' && path.length === 2),
      'every row is a complete "eevee -> x" line',
    );
    assert.ok(
      paths.some((path) => path[1] === 'vaporeon'),
      'vaporeon is one of them',
    );
  });

  test('a branched evolution only shows its own line', async function (assert) {
    await visit('/pokemon/134');

    assert.deepEqual(renderedPaths(), [['eevee', 'vaporeon']]);
    assert.dom('.evolution-link.is-current').hasText('vaporeon');
  });

  test('a pokemon without evolutions says so', async function (assert) {
    await visit('/pokemon/151');

    assert.deepEqual(renderedPaths(), [['mew']]);
    assert.dom('.evolution-status').hasText('This Pokémon does not evolve.');
  });
});
