import { module, test } from 'qunit';
import { visit, click, waitUntil, currentURL } from '@ember/test-helpers';
import { setupApplicationTest } from 'pokedex-challenge/tests/helpers';

module('Acceptance | pokemon navigation', function (hooks) {
  setupApplicationTest(hooks);

  test('clicking an evolution stage link reloads the detail page content (STORY-04 regression)', async function (assert) {
    await visit('/pokemon/1');
    assert.strictEqual(currentURL(), '/pokemon/1');

    await waitUntil(() => document.querySelector('.detail-name'));
    assert.dom('.detail-name').containsText('bulbasaur');

    await waitUntil(() => document.querySelector('.evolution-link'));
    // Click the second stage (ivysaur) — the first stage's link points
    // back to the current pokemon (bulbasaur) and wouldn't exercise
    // the navigation-reload bug this test guards against.
    await click(
      '.evolution-line .evolution-stage:nth-child(2) .evolution-link',
    );

    assert.strictEqual(currentURL(), '/pokemon/2');

    // The bug this test guards against: clicking a same-route link updates
    // the URL but PokemonDetail/EvolutionChain kept showing bulbasaur's
    // data because their constructors don't re-run on argument changes.
    await waitUntil(() =>
      document.querySelector('.detail-name')?.textContent.includes('ivysaur'),
    );
    assert.dom('.detail-name').containsText('ivysaur');
    assert.dom('.detail-id').hasText('#2');

    await waitUntil(() => document.querySelector('.evolution-line'));
    const links = [...document.querySelectorAll('.evolution-link')].map((el) =>
      el.textContent.trim(),
    );
    assert.deepEqual(
      links,
      ['bulbasaur', 'ivysaur', 'venusaur'],
      'evolution chain reloads for the new pokemon rather than staying stuck on the previous one',
    );
  });

  test('navigating back to a previously-visited pokemon reloads its content (STORY-04 regression)', async function (assert) {
    await visit('/pokemon/1');
    await waitUntil(() => document.querySelector('.detail-name'));
    assert.dom('.detail-name').containsText('bulbasaur');

    await visit('/pokemon/2');
    await waitUntil(() =>
      document.querySelector('.detail-name')?.textContent.includes('ivysaur'),
    );
    assert.dom('.detail-name').containsText('ivysaur');

    // Simulate the browser back button: navigating to a previously-visited
    // /pokemon/:id route reuses the same component instance the same way
    // clicking back/forward does, so this exercises the identical
    // reload-on-argument-change code path as STORY-04's fix.
    await visit('/pokemon/1');
    await waitUntil(() =>
      document.querySelector('.detail-name')?.textContent.includes('bulbasaur'),
    );

    assert.dom('.detail-name').containsText('bulbasaur');
    assert.dom('.detail-id').hasText('#1');
    assert
      .dom('.detail-name')
      .doesNotContainText('ivysaur', 'stale ivysaur content is gone');
  });
});
