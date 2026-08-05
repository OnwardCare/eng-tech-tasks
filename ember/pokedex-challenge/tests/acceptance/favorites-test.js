import { module, test } from 'qunit';
import { visit, click } from '@ember/test-helpers';
import { setupApplicationTest } from 'pokedex-challenge/tests/helpers';

const FAVORITES_KEY = 'pokedex:favorites';
const FIRST_CARD = '.pokemon-grid > .pokemon-card:nth-child(1)';

module('Acceptance | favorites', function (hooks) {
  setupApplicationTest(hooks);

  hooks.beforeEach(function () {
    localStorage.removeItem(FAVORITES_KEY);
  });

  hooks.afterEach(function () {
    localStorage.removeItem(FAVORITES_KEY);
  });

  test('starring a pokemon updates the nav count, the card, and persists to localStorage', async function (assert) {
    await visit('/');
    assert.dom('.nav-favorites').hasText('Favorites (0)');
    assert
      .dom(`${FIRST_CARD} .favorite-button`)
      .doesNotHaveClass('is-favorite');

    await click(`${FIRST_CARD} .favorite-button`);

    assert.dom(`${FIRST_CARD} .favorite-button`).hasClass('is-favorite');
    assert.dom('.nav-favorites').hasText('Favorites (1)');

    const stored = JSON.parse(localStorage.getItem(FAVORITES_KEY));
    assert.strictEqual(stored.length, 1);
    assert.strictEqual(stored[0].name, 'bulbasaur');

    await visit('/favorites');
    assert.dom('.pokemon-grid .pokemon-card').exists({ count: 1 });
    assert.dom('.pokemon-grid .pokemon-name').hasText('bulbasaur');
  });

  test('favorites persisted in localStorage are reflected on a fresh visit', async function (assert) {
    localStorage.setItem(
      FAVORITES_KEY,
      JSON.stringify([
        { id: 1, name: 'bulbasaur', sprite: 'https://example.com/bulba.png' },
      ]),
    );

    await visit('/');

    assert.dom('.nav-favorites').hasText('Favorites (1)');
    assert.dom(`${FIRST_CARD} .favorite-button`).hasClass('is-favorite');

    await visit('/favorites');
    assert.dom('.pokemon-grid .pokemon-card').exists({ count: 1 });
    assert.dom('.pokemon-grid .pokemon-name').hasText('bulbasaur');
  });
});
