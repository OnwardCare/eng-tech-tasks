import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, settled } from '@ember/test-helpers';

const STORAGE_KEY = 'pokedex:favorites';

module('Unit | Service | favorites', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    localStorage.clear();
  });

  hooks.afterEach(function () {
    localStorage.clear();
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

  test('add() writes through to localStorage', function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    favorites.add({
      id: 25,
      name: 'pikachu',
      sprite: '/sprites/25.png',
      types: ['electric'],
    });

    assert.deepEqual(JSON.parse(localStorage.getItem(STORAGE_KEY)), [
      {
        id: 25,
        name: 'pikachu',
        sprite: '/sprites/25.png',
        types: ['electric'],
      },
    ]);
  });

  test('stored favorites are read back on boot', function (assert) {
    localStorage.setItem(
      STORAGE_KEY,
      JSON.stringify([{ id: 1, name: 'bulbasaur' }]),
    );

    const favorites = this.owner.lookup('service:favorites');

    assert.strictEqual(favorites.count, 1);
    assert.true(favorites.isFavorite(1));
  });

  test('only card fields are stored, whatever the caller passes', function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    favorites.add({
      id: 1,
      name: 'bulbasaur',
      sprite: '/sprites/1.png',
      types: ['grass'],
      artwork: '/artwork/1.png',
      stats: [{ name: 'hp', value: 45 }],
    });

    assert.deepEqual(Object.keys(favorites.items[0]).sort(), [
      'id',
      'name',
      'sprite',
      'types',
    ]);
  });

  test('corrupt storage is ignored rather than thrown', function (assert) {
    localStorage.setItem(STORAGE_KEY, 'not json');

    assert.strictEqual(this.owner.lookup('service:favorites').count, 0);
  });

  test('toggle() adds then removes, and add() does not duplicate', function (assert) {
    const favorites = this.owner.lookup('service:favorites');
    const pikachu = { id: 25, name: 'pikachu' };

    favorites.toggle(pikachu);
    favorites.add(pikachu);
    assert.strictEqual(favorites.count, 1);

    favorites.toggle(pikachu);
    assert.strictEqual(favorites.count, 0);
    assert.deepEqual(JSON.parse(localStorage.getItem(STORAGE_KEY)), []);
  });
});
