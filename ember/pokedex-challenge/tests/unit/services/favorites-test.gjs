import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, settled } from '@ember/test-helpers';

const FAVORITES_KEY = 'pokedex:favorites';

module('Unit | Service | favorites', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    localStorage.removeItem(FAVORITES_KEY);
  });

  hooks.afterEach(function () {
    localStorage.removeItem(FAVORITES_KEY);
  });

  test('count updates after add()', async function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    await render(
      <template>
        <span id="count">{{favorites.count}}</span>
      </template>,
    );
    assert.dom('#count').hasText('0');

    favorites.add({ id: 25, name: 'pikachu' });
    await settled();

    assert.dom('#count').hasText('1');
  });

  test('remove() drops a favorite', function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    favorites.add({ id: 25, name: 'pikachu' });
    favorites.remove(25);

    assert.strictEqual(favorites.count, 0);
    assert.false(favorites.isFavorite(25));
  });

  test('persists favorites to localStorage', function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    favorites.add({ id: 25, name: 'pikachu' });

    assert.deepEqual(JSON.parse(localStorage.getItem(FAVORITES_KEY)), [
      { id: 25, name: 'pikachu' },
    ]);
  });

  test('normalizes favorited entries to a consistent shape', function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    favorites.add({
      id: 1,
      name: 'bulbasaur',
      height: 7,
      artwork: 'https://example.com/bulbasaur-artwork.png',
    });

    assert.deepEqual(favorites.items, [
      {
        id: 1,
        name: 'bulbasaur',
        sprite: 'https://example.com/bulbasaur-artwork.png',
      },
    ]);
  });

  test('hydrates from localStorage on init', function (assert) {
    localStorage.setItem(
      FAVORITES_KEY,
      JSON.stringify([{ id: 25, name: 'pikachu' }]),
    );

    const favorites = this.owner.lookup('service:favorites');

    assert.strictEqual(favorites.count, 1);
    assert.true(favorites.isFavorite(25));
  });
});
