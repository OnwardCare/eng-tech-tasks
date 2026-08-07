import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, settled } from '@ember/test-helpers';

const STORAGE_KEY = 'pokedex-challenge:favorites';

module('Unit | Service | favorites', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    localStorage.removeItem(STORAGE_KEY);
  });

  hooks.afterEach(function () {
    localStorage.removeItem(STORAGE_KEY);
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

  test('add() persists to localStorage', function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    favorites.add({ id: 25, name: 'pikachu' });

    const stored = JSON.parse(localStorage.getItem(STORAGE_KEY));
    assert.deepEqual(stored, [{ id: 25, name: 'pikachu' }]);
  });

  test('remove() updates persisted localStorage', function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    favorites.add({ id: 25, name: 'pikachu' });
    favorites.remove(25);

    const stored = JSON.parse(localStorage.getItem(STORAGE_KEY));
    assert.deepEqual(stored, []);
  });

  test('a fresh service instance reads previously persisted favorites', function (assert) {
    localStorage.setItem(
      STORAGE_KEY,
      JSON.stringify([{ id: 1, name: 'bulbasaur' }]),
    );

    const favorites = this.owner.lookup('service:favorites');

    assert.strictEqual(favorites.count, 1);
    assert.true(favorites.isFavorite(1));
  });

  test('corrupt localStorage data does not crash and resets to empty', function (assert) {
    localStorage.setItem(STORAGE_KEY, 'not-json{{{');

    const favorites = this.owner.lookup('service:favorites');

    assert.strictEqual(favorites.count, 0);
  });
});
