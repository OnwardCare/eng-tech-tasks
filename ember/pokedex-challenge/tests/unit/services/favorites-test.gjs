import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, settled } from '@ember/test-helpers';

const STORAGE_KEY = 'pokedex:favorites';

module('Unit | Service | favorites', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
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

  test('toggle() adds and then removes a pokemon', async function (assert) {
    const favorites = this.owner.lookup('service:favorites');
    const pikachu = { id: 25, name: 'pikachu' };

    favorites.toggle(pikachu);
    assert.true(favorites.isFavorite(25), 'favorited after first toggle');

    favorites.toggle(pikachu);
    assert.false(favorites.isFavorite(25), 'unfavorited after second toggle');
  });

  test('add()/remove() persist to localStorage', function (assert) {
    const favorites = this.owner.lookup('service:favorites');
    const pikachu = { id: 25, name: 'pikachu' };

    favorites.add(pikachu);
    assert.deepEqual(
      JSON.parse(localStorage.getItem(STORAGE_KEY)),
      [pikachu],
      'persisted after add()',
    );

    favorites.remove(25);
    assert.deepEqual(
      JSON.parse(localStorage.getItem(STORAGE_KEY)),
      [],
      'persisted after remove()',
    );
  });

  test('reads previously persisted favorites on creation (survives reload)', function (assert) {
    const pikachu = { id: 25, name: 'pikachu' };
    localStorage.setItem(STORAGE_KEY, JSON.stringify([pikachu]));

    const favorites = this.owner.lookup('service:favorites');

    assert.strictEqual(favorites.count, 1);
    assert.true(favorites.isFavorite(25));
  });
});
