import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, settled } from '@ember/test-helpers';

module('Unit | Service | favorites', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    localStorage.removeItem('pokedex-challenge:favorites');
  });

  hooks.afterEach(function () {
    localStorage.removeItem('pokedex-challenge:favorites');
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

  test('toggle adds and removes a favorite', function (assert) {
    const favorites = this.owner.lookup('service:favorites');
    const pikachu = { id: 25, name: 'pikachu', sprite: 'pikachu.png' };

    favorites.toggle(pikachu);
    assert.true(favorites.isFavorite(25), 'added on first toggle');

    favorites.toggle(pikachu);
    assert.false(favorites.isFavorite(25), 'removed on second toggle');
  });

  test('adding the same pokemon twice does not duplicate it', function (assert) {
    const favorites = this.owner.lookup('service:favorites');
    const pikachu = { id: 25, name: 'pikachu', sprite: 'pikachu.png' };

    favorites.add(pikachu);
    favorites.add(pikachu);

    assert.strictEqual(favorites.count, 1);
  });

  test('favorites persist to localStorage and are reloaded by a new instance', function (assert) {
    const favorites = this.owner.lookup('service:favorites');
    favorites.add({ id: 25, name: 'pikachu', sprite: 'pikachu.png' });

    const persisted = JSON.parse(
      localStorage.getItem('pokedex-challenge:favorites'),
    );
    assert.strictEqual(persisted.length, 1);
    assert.strictEqual(persisted[0].id, 25);

    favorites.remove(25);
    const afterRemove = JSON.parse(
      localStorage.getItem('pokedex-challenge:favorites'),
    );
    assert.strictEqual(afterRemove.length, 0);
  });
});
