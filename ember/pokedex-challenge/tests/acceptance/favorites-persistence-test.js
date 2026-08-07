import { module, test } from 'qunit';
import { visit, click } from '@ember/test-helpers';
import { setupApplicationTest } from 'pokedex-challenge/tests/helpers';

const STORAGE_KEY = 'pokedex-challenge:favorites';

module('Acceptance | favorites persistence', function (hooks) {
  setupApplicationTest(hooks);

  hooks.beforeEach(function () {
    localStorage.removeItem(STORAGE_KEY);
  });

  hooks.afterEach(function () {
    localStorage.removeItem(STORAGE_KEY);
  });

  test('favorites persisted in localStorage are shown on /favorites after a fresh visit', async function (assert) {
    localStorage.setItem(
      STORAGE_KEY,
      JSON.stringify([
        { id: 25, name: 'pikachu', sprite: '', types: ['electric'] },
      ]),
    );

    await visit('/favorites');

    assert.dom('.nav-favorites').hasText('Favorites (1)');
    assert.dom('.pokemon-grid .pokemon-card').exists({ count: 1 });
    assert.dom('.pokemon-card .pokemon-name').hasText('pikachu');
  });

  test('toggling a favorite from the index page writes through to localStorage and updates the nav count', async function (assert) {
    await visit('/');
    assert.dom('.nav-favorites').hasText('Favorites (0)');

    await click('.pokemon-card .favorite-button');

    assert.dom('.nav-favorites').hasText('Favorites (1)');

    const stored = JSON.parse(localStorage.getItem(STORAGE_KEY));
    assert.strictEqual(stored.length, 1);
  });
});
