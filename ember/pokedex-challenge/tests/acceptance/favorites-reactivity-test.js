import { module, test } from 'qunit';
import { visit, find, click, findAll, waitUntil } from '@ember/test-helpers';
import { setupApplicationTest } from 'pokedex-challenge/tests/helpers';

module('Acceptance | Favorites Reactivity', function (hooks) {
  setupApplicationTest(hooks);

  test('starring a pokemon updates the star icon immediately', async function (assert) {
    await visit('/');

    // Find the first card and its star button
    const firstCard = find('[data-test-pokemon-card]');
    const starButton = firstCard.querySelector('[data-test-favorite-button]');

    // Initially should be empty star
    assert.false(
      starButton.classList.contains('is-favorite'),
      'Star is empty initially',
    );
    assert.dom(starButton).hasText('☆');

    // Click the star
    await click('[data-test-pokemon-card]:first-child [data-test-favorite-button]');

    // Should now be filled
    assert.true(
      starButton.classList.contains('is-favorite'),
      'Star is filled after click',
    );
    assert.dom(starButton).hasText('★');
  });

  test('starring a pokemon updates nav count immediately', async function (assert) {
    await visit('/');

    const navCount = find('[data-test-nav-favorites-count]');
    const initialCount = parseInt(navCount.textContent);

    // Star the first pokemon
    await click('[data-test-pokemon-card]:first-child [data-test-favorite-button]');

    // Nav count should increment immediately
    assert.strictEqual(
      parseInt(navCount.textContent),
      initialCount + 1,
      'Nav count incremented',
    );
  });

  test('unstarring a pokemon updates nav count immediately', async function (assert) {
    await visit('/');

    const navCount = find('[data-test-nav-favorites-count]');
    const initialCount = parseInt(navCount.textContent);

    // Star the first pokemon
    await click('[data-test-pokemon-card]:first-child [data-test-favorite-button]');
    assert.strictEqual(
      parseInt(navCount.textContent),
      initialCount + 1,
      'Count incremented after star',
    );

    // Unstar it
    await click('[data-test-pokemon-card]:first-child [data-test-favorite-button]');

    // Count should be back to initial
    assert.strictEqual(
      parseInt(navCount.textContent),
      initialCount,
      'Nav count back to initial after unstar',
    );
  });

  test('toggling a favorite multiple times results in correct final state', async function (assert) {
    await visit('/');

    const firstCardButton = find(
      '[data-test-pokemon-card]:first-child [data-test-favorite-button]',
    );
    const navCount = find('[data-test-nav-favorites-count]');
    const initialCount = parseInt(navCount.textContent);

    // Toggle: unstarred → starred → unstarred
    await click('[data-test-pokemon-card]:first-child [data-test-favorite-button]');
    assert.true(
      firstCardButton.classList.contains('is-favorite'),
      'Starred after first click',
    );

    await click('[data-test-pokemon-card]:first-child [data-test-favorite-button]');
    assert.false(
      firstCardButton.classList.contains('is-favorite'),
      'Unstarred after second click',
    );

    // Count should be back to initial
    assert.strictEqual(
      parseInt(navCount.textContent),
      initialCount,
      'Nav count back to initial after odd number of toggles',
    );
  });

  test('rapid toggles on same pokemon result in correct state', async function (assert) {
    await visit('/');

    const starButton = find(
      '[data-test-pokemon-card]:first-child [data-test-favorite-button]',
    );
    const navCount = find('[data-test-nav-favorites-count]');
    const initialCount = parseInt(navCount.textContent);

    // Rapid toggles: star → unstar → star → unstar → star
    for (let i = 0; i < 5; i++) {
      await click('[data-test-pokemon-card]:first-child [data-test-favorite-button]');
    }

    // After odd number of toggles, should be starred
    assert.true(
      starButton.classList.contains('is-favorite'),
      'Star filled after 5 toggles',
    );
    assert.strictEqual(
      parseInt(navCount.textContent),
      initialCount + 1,
      'Nav count increased by 1 after 5 toggles',
    );
  });

  test('starring multiple pokemon updates nav count correctly', async function (assert) {
    await visit('/');

    const navCount = find('[data-test-nav-favorites-count]');
    const initialCount = parseInt(navCount.textContent);

    // Star first 3 pokemon
    const cardButtons = findAll('[data-test-pokemon-card] [data-test-favorite-button]');
    for (let i = 0; i < 3; i++) {
      await click(cardButtons[i]);
    }

    assert.strictEqual(
      parseInt(navCount.textContent),
      initialCount + 3,
      'Nav count increased by 3',
    );

    // All 3 should be starred
    for (let i = 0; i < 3; i++) {
      assert.true(
        cardButtons[i].classList.contains('is-favorite'),
        `Pokemon ${i} is starred`,
      );
    }
  });

  test('grid cards and detail page stay in sync (navigate after starring)', async function (assert) {
    await visit('/');

    // Find first card
    const firstCard = find('[data-test-pokemon-card]');
    const firstCardId = firstCard.textContent; // Will include the pokemon number

    // Star it on the grid
    const gridStarButton = find(
      '[data-test-pokemon-card]:first-child [data-test-favorite-button]',
    );
    await click(gridStarButton);
    assert.true(
      gridStarButton.classList.contains('is-favorite'),
      'Star filled on grid',
    );

    // Navigate to detail page (click the pokemon link)
    await click('[data-test-pokemon-card]:first-child .pokemon-link');
    await waitUntil(() => find('.detail-name'));

    // Find the star button on detail page
    const detailStarButton = find('[data-test-favorite-button]');

    // Should still be starred
    assert.true(
      detailStarButton.classList.contains('is-favorite'),
      'Star still filled on detail page',
    );
  });

  test('grid and detail page stay in sync (star on detail, check grid)', async function (assert) {
    await visit('/');

    // Navigate to first pokemon detail page
    await click('[data-test-pokemon-card]:first-child .pokemon-link');
    await waitUntil(() => find('[data-test-favorite-button]'));

    // Star on detail page
    const detailStarButton = find('[data-test-favorite-button]');
    await click(detailStarButton);
    assert.true(
      detailStarButton.classList.contains('is-favorite'),
      'Star filled on detail page',
    );

    // Go back to grid
    await visit('/');
    await waitUntil(() => find('[data-test-pokemon-card]'));

    // First pokemon's star should be filled on grid
    const gridStarButton = find(
      '[data-test-pokemon-card]:first-child [data-test-favorite-button]',
    );
    assert.true(
      gridStarButton.classList.contains('is-favorite'),
      'Star also filled on grid card',
    );
  });

  test('unstarring from detail page updates grid immediately upon return', async function (assert) {
    await visit('/');

    // Star the first pokemon
    const gridStarButton = find(
      '[data-test-pokemon-card]:first-child [data-test-favorite-button]',
    );
    await click(gridStarButton);

    // Navigate to detail page
    await click('[data-test-pokemon-card]:first-child .pokemon-link');
    await waitUntil(() => find('[data-test-favorite-button]'));

    // Unstar on detail page
    const detailStarButton = find('[data-test-favorite-button]');
    await click(detailStarButton);
    assert.false(
      detailStarButton.classList.contains('is-favorite'),
      'Star empty on detail page after unstar',
    );

    // Go back to grid
    await visit('/');
    await waitUntil(() => find('[data-test-pokemon-card]'));

    // First pokemon's star should now be empty on grid
    const updatedGridStarButton = find(
      '[data-test-pokemon-card]:first-child [data-test-favorite-button]',
    );
    assert.false(
      updatedGridStarButton.classList.contains('is-favorite'),
      'Star empty on grid after unstar from detail page',
    );
  });
});
