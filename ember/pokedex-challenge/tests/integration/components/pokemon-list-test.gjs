import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, click, find, findAll, waitUntil } from '@ember/test-helpers';
import PokemonList from 'pokedex-challenge/components/pokemon-list';

const firstPage = Array.from({ length: 20 }, (_, i) => ({
  id: i + 1,
  name: `page1-pokemon-${i + 1}`,
  sprite: '',
  types: ['normal'],
}));

module('Integration | Component | pokemon-list', function (hooks) {
  setupRenderingTest(hooks);

  test('previous is disabled on the first page and shows the seeded page', async function (assert) {
    await render(<template><PokemonList @pokemon={{firstPage}} /></template>);

    assert.dom('.page-button--previous').isDisabled();
    assert.dom('.page-button--next').isNotDisabled();
    assert.deepEqual(
      findAll('.pokemon-name').map((el) => el.textContent.trim()),
      firstPage.map((p) => p.name),
    );
  });

  test('paging forward then back returns the exact first page without refetching it', async function (assert) {
    await render(<template><PokemonList @pokemon={{firstPage}} /></template>);

    await click('.page-button--next');
    await waitUntil(
      () =>
        findAll('.pokemon-name')[0]?.textContent.trim() !== 'page1-pokemon-1',
      { timeout: 5000 },
    );
    assert.dom('.page-button--previous').isNotDisabled();
    const secondPageNames = findAll('.pokemon-name').map((el) =>
      el.textContent.trim(),
    );
    assert.notDeepEqual(
      secondPageNames,
      firstPage.map((p) => p.name),
      'second page shows different pokemon',
    );

    await click('.page-button--previous');

    assert.dom('.page-button--previous').isDisabled();
    assert.deepEqual(
      findAll('.pokemon-name').map((el) => el.textContent.trim()),
      firstPage.map((p) => p.name),
      'back on page 1, showing the exact original seeded page',
    );
  });

  test('shows an error and rolls back the offset when a page fails to load', async function (assert) {
    await render(<template><PokemonList @pokemon={{firstPage}} /></template>);

    const originalFetch = window.fetch;
    window.fetch = () => Promise.resolve(new Response('{}', { status: 500 }));

    try {
      await click('.page-button--next');
      await waitUntil(() => find('.pagination-error'));

      assert.dom('.pagination-error').exists();
      assert
        .dom('.page-button--previous')
        .isDisabled('rolled back to the first page');
      assert.deepEqual(
        findAll('.pokemon-name').map((el) => el.textContent.trim()),
        firstPage.map((p) => p.name),
        'still showing the original first page after the failed fetch',
      );
    } finally {
      window.fetch = originalFetch;
    }
  });
});
