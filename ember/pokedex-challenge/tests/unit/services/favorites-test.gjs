import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, settled } from '@ember/test-helpers';
import { STORAGE_KEY } from 'pokedex-challenge/services/favorites';

const PIKACHU = {
  id: 25,
  name: 'pikachu',
  sprite: '/25.png',
  types: ['electric'],
};
const EEVEE = { id: 133, name: 'eevee', sprite: '/133.png', types: ['normal'] };

function stored() {
  return JSON.parse(localStorage.getItem(STORAGE_KEY) ?? 'null');
}

module('Unit | Service | favorites', function (hooks) {
  setupRenderingTest(hooks);

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

  test('add/remove/toggle keep isFavorite in step', function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    favorites.add(PIKACHU);
    assert.true(favorites.isFavorite(25));
    assert.true(favorites.isFavorite('25'), 'ids compare by value');

    favorites.add(PIKACHU);
    assert.strictEqual(favorites.count, 1, 'starring twice is a no-op');

    favorites.toggle(EEVEE);
    assert.strictEqual(favorites.count, 2);

    favorites.toggle(EEVEE);
    assert.false(favorites.isFavorite(133));

    favorites.remove(25);
    assert.strictEqual(favorites.count, 0);
  });

  test('favorites are persisted and read back by a new instance', function (assert) {
    this.owner.lookup('service:favorites').add(PIKACHU);

    assert.deepEqual(stored(), [PIKACHU], 'the card record is persisted');

    const reloaded = this.owner.factoryFor('service:favorites').create();

    assert.strictEqual(reloaded.count, 1);
    assert.true(reloaded.isFavorite(25));
    assert.deepEqual(reloaded.items, [PIKACHU]);
  });

  test('a pokemon starred from the detail page keeps a usable sprite', function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    favorites.add({ id: 6, name: 'charizard', artwork: '/6-artwork.png' });

    assert.deepEqual(favorites.items, [
      { id: 6, name: 'charizard', sprite: '/6-artwork.png', types: [] },
    ]);
  });

  test('unreadable stored data is ignored', function (assert) {
    const load = () =>
      this.owner.factoryFor('service:favorites').create().count;

    localStorage.setItem(STORAGE_KEY, 'not json');
    assert.strictEqual(load(), 0, 'invalid json');

    localStorage.setItem(STORAGE_KEY, '{"nope": true}');
    assert.strictEqual(load(), 0, 'not a list');

    localStorage.setItem(STORAGE_KEY, '[{"name": "missing an id"}]');
    assert.strictEqual(load(), 0, 'entries without an id');
  });

  test('favorites starred in another tab show up here', async function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    await render(
      <template>
        <span id="count">{{favorites.count}}</span>
      </template>,
    );

    localStorage.setItem(STORAGE_KEY, JSON.stringify([PIKACHU, EEVEE]));
    window.dispatchEvent(
      new StorageEvent('storage', {
        key: STORAGE_KEY,
        storageArea: localStorage,
      }),
    );
    await settled();

    assert.dom('#count').hasText('2');
    assert.true(favorites.isFavorite(133));
  });
});
