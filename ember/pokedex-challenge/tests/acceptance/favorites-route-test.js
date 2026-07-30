import { module, test } from 'qunit';
import { visit, find, click, findAll, waitUntil } from '@ember/test-helpers';
import { setupApplicationTest } from 'pokedex-challenge/tests/helpers';

module('Acceptance | Favorites Route', function (hooks) {
  setupApplicationTest(hooks);

  test('favorites page shows favorited pokemon', async function (assert) {
    // Navigate to a pokemon and star it
    await visit('/');
    await click('[data-test-pokemon-card]:first-child [data-test-favorite-button]');

    // Navigate to favorites
    await visit('/favorites');
    await waitUntil(() => find('[data-test-pokemon-card]'));

    // Should show the favorited pokemon
    const cards = findAll('[data-test-pokemon-card]');
    assert.strictEqual(cards.length, 1, 'One favorited pokemon shown');
  });

  test('favorites page shows empty state when no favorites', async function (assert) {
    await visit('/favorites');

    // Should show empty state (no cards)
    const cards = findAll('[data-test-pokemon-card]');
    assert.strictEqual(cards.length, 0, 'No pokemon shown');

    // Should show empty state message
    const emptyState = find('.empty-state');
    assert.ok(emptyState, 'Empty state message displayed');
    assert.dom(emptyState).containsText(
      'No favorites yet',
      'Message tells user to star pokemon',
    );
  });

  test('favorites page shows multiple favorited pokemon', async function (assert) {
    await visit('/');

    // Star first 3 pokemon
    const firstCards = findAll('[data-test-pokemon-card]');
    for (let i = 0; i < 3; i++) {
      await click(firstCards[i].querySelector('[data-test-favorite-button]'));
    }

    // Go to favorites
    await visit('/favorites');
    await waitUntil(() => find('[data-test-pokemon-card]'));

    const favoriteCards = findAll('[data-test-pokemon-card]');
    assert.strictEqual(favoriteCards.length, 3, 'Three favorite pokemon shown');
  });

  test('favorites page updates when a pokemon is unfavorited from detail page', async function (assert) {
    // Star a pokemon and navigate to favorites
    await visit('/');
    const firstCard = find('[data-test-pokemon-card]');
    await click(firstCard.querySelector('[data-test-favorite-button]'));

    await visit('/favorites');
    await waitUntil(() => find('[data-test-pokemon-card]'));
    assert.strictEqual(
      findAll('[data-test-pokemon-card]').length,
      1,
      'One favorite shown initially',
    );

    // Navigate to detail page
    await click('[data-test-pokemon-card] .pokemon-link');
    await waitUntil(() => find('[data-test-favorite-button]'));

    // Unstar the pokemon
    const detailStarButton = find('[data-test-favorite-button]');
    await click(detailStarButton);

    // Go back to favorites
    await visit('/favorites');
    await waitUntil(() => {
      const cards = findAll('[data-test-pokemon-card]');
      return cards.length === 0 || find('.empty-state');
    });

    // Should now be empty or show empty state
    const cards = findAll('[data-test-pokemon-card]');
    const emptyState = find('.empty-state');
    assert.ok(
      cards.length === 0 || emptyState,
      'Favorites page updated after unstar from detail page',
    );
  });

  test('favorites page updates when a pokemon is unfavorited from the favorites page itself', async function (assert) {
    // Star a pokemon
    await visit('/');
    await click('[data-test-pokemon-card]:first-child [data-test-favorite-button]');

    // Go to favorites
    await visit('/favorites');
    await waitUntil(() => find('[data-test-pokemon-card]'));

    const initialCards = findAll('[data-test-pokemon-card]');
    assert.strictEqual(initialCards.length, 1, 'One favorite shown');

    // Unstar from favorites page
    const starButton = find('[data-test-pokemon-card] [data-test-favorite-button]');
    await click(starButton);

    // Should update immediately
    await waitUntil(() => {
      const cards = findAll('[data-test-pokemon-card]');
      return cards.length === 0 || find('.empty-state');
    });

    const finalCards = findAll('[data-test-pokemon-card]');
    const emptyState = find('.empty-state');
    assert.ok(
      finalCards.length === 0 || emptyState,
      'Favorites page shows empty state after unstar',
    );
  });

  test('favorites page displays pokemon grid when favorites exist', async function (assert) {
    // Star 3 pokemon
    await visit('/');
    const cards = findAll('[data-test-pokemon-card]');
    for (let i = 0; i < 3; i++) {
      await click(cards[i].querySelector('[data-test-favorite-button]'));
    }

    // Go to favorites
    await visit('/favorites');
    await waitUntil(() => find('[data-test-pokemon-card]'));

    // Should have pokemon grid
    const gridDiv = find('.pokemon-grid');
    assert.ok(gridDiv, 'Pokemon grid is displayed');

    // Should not show empty state
    const emptyState = find('.empty-state');
    assert.notOk(emptyState, 'Empty state not shown');

    // Should show all 3 favorites
    const favoriteCards = findAll('[data-test-pokemon-card]');
    assert.strictEqual(favoriteCards.length, 3, 'All 3 favorites shown');
  });

  test('empty state message is shown when all favorites are removed', async function (assert) {
    // Star a pokemon
    await visit('/');
    const firstCard = find('[data-test-pokemon-card]');
    await click(firstCard.querySelector('[data-test-favorite-button]'));

    // Go to favorites
    await visit('/favorites');
    await waitUntil(() => find('[data-test-pokemon-card]'));

    // Unstar it
    await click('[data-test-pokemon-card] [data-test-favorite-button]');

    // Should show empty state
    await waitUntil(() => find('.empty-state'));
    const emptyState = find('.empty-state');
    assert.ok(emptyState, 'Empty state message displayed');
    assert.dom(emptyState).containsText('No favorites yet');
  });

  test('favorites page title is set correctly', async function (assert) {
    await visit('/favorites');

    // Check page title (ember-page-title sets document.title)
    assert.ok(
      document.title.includes('Favorites'),
      'Page title includes "Favorites"',
    );
  });

  test('navigating between favorited pokemon updates the view', async function (assert) {
    // Star first 2 pokemon
    await visit('/');
    const cards = findAll('[data-test-pokemon-card]');
    await click(cards[0].querySelector('[data-test-favorite-button]'));
    await click(cards[1].querySelector('[data-test-favorite-button]'));

    // Go to favorites
    await visit('/favorites');
    await waitUntil(() => find('[data-test-pokemon-card]'));
    assert.strictEqual(
      findAll('[data-test-pokemon-card]').length,
      2,
      'Two favorites shown',
    );

    // Click first favorite to go to detail
    await click('[data-test-pokemon-card]:first-child .pokemon-link');
    await waitUntil(() => find('.detail-name'));

    // Go back to favorites
    await visit('/favorites');
    await waitUntil(() => find('[data-test-pokemon-card]'));

    // Should still show 2 favorites
    assert.strictEqual(
      findAll('[data-test-pokemon-card]').length,
      2,
      'Still showing 2 favorites after navigation',
    );
  });
});
