import { module, test } from 'qunit';
import { setupTest } from 'pokedex-challenge/tests/helpers';

const STORAGE_KEY = 'my_favorites';

module('Unit | Service | favorites', function (hooks) {
  setupTest(hooks);

  hooks.beforeEach(function () {
    localStorage.removeItem(STORAGE_KEY);
  });

  hooks.afterEach(function () {
    localStorage.removeItem(STORAGE_KEY);
  });

  test('add and remove update count and isFavorite', function (assert) {
    const favorites = this.owner.lookup('service:favorites');
    const pikachu = { id: 25, name: 'pikachu' };

    assert.strictEqual(favorites.count, 0);
    assert.false(favorites.isFavorite(25));

    favorites.add(pikachu);

    assert.strictEqual(favorites.count, 1);
    assert.true(favorites.isFavorite(25));

    favorites.remove(25);

    assert.strictEqual(favorites.count, 0);
    assert.false(favorites.isFavorite(25));
  });

  test('toggle adds then removes a favorite', function (assert) {
    const favorites = this.owner.lookup('service:favorites');
    const pikachu = { id: 25, name: 'pikachu' };

    favorites.toggle(pikachu);
    assert.true(favorites.isFavorite(25));

    favorites.toggle(pikachu);
    assert.false(favorites.isFavorite(25));
  });

  test('persists favorites to localStorage', function (assert) {
    const favorites = this.owner.lookup('service:favorites');
    favorites.add({ id: 1, name: 'bulbasaur' });

    const stored = JSON.parse(localStorage.getItem(STORAGE_KEY));
    assert.strictEqual(stored.length, 1);
    assert.strictEqual(stored[0].name, 'bulbasaur');
  });
});
