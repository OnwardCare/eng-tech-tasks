import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, settled } from '@ember/test-helpers';

// Must match STORAGE_KEY in app/services/favorites.js
const STORAGE_KEY = 'pokedex-challenge:favorites';

const PIKACHU = {
  id: 25,
  name: 'pikachu',
  sprite: 'pikachu-sprite.png',
  artwork: 'pikachu-artwork.png',
  types: ['electric'],
};

const CHARIZARD = {
  id: 6,
  name: 'charizard',
  artwork: 'charizard-artwork.png',
};

const MEWTWO = {
  id: 150,
  name: 'mewtwo',
};

module('Unit | Service | favorites', function (hooks) {
  setupRenderingTest(hooks);

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

  test('starts empty when localStorage has nothing stored', function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    assert.strictEqual(favorites.count, 0);
    assert.deepEqual(favorites.items, []);
  });

  test('isFavorite() reflects whether a pokemon has been added', function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    assert.notOk(favorites.isFavorite(25), 'not a favorite before add()');

    favorites.add(PIKACHU);

    assert.ok(favorites.isFavorite(25), 'is a favorite after add()');
    assert.notOk(favorites.isFavorite(6), 'other ids remain unaffected');
  });

  test('add() normalizes the pokemon before storing it', function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    favorites.add(PIKACHU);

    assert.deepEqual(favorites.items, [
      {
        id: 25,
        name: 'pikachu',
        sprite: 'pikachu-sprite.png',
        types: ['electric'],
      },
    ]);
  });

  test('add() falls back to artwork when sprite is missing', function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    favorites.add(CHARIZARD);

    assert.strictEqual(favorites.items[0].sprite, 'charizard-artwork.png');
  });

  test('add() falls back to null sprite and empty types when neither is provided', function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    favorites.add(MEWTWO);

    assert.strictEqual(favorites.items[0].sprite, null);
    assert.deepEqual(favorites.items[0].types, []);
  });

  test('remove() removes only the matching id', function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    favorites.add(PIKACHU);
    favorites.add(CHARIZARD);

    favorites.remove(25);

    assert.strictEqual(favorites.count, 1);
    assert.notOk(favorites.isFavorite(25));
    assert.ok(favorites.isFavorite(6));
  });

  test('toggle() adds when not a favorite and removes when it is', function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    favorites.toggle(PIKACHU);
    assert.ok(favorites.isFavorite(25), 'added on first toggle');

    favorites.toggle(PIKACHU);
    assert.notOk(favorites.isFavorite(25), 'removed on second toggle');
  });

  test('add() and remove() persist changes to localStorage', function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    favorites.add(PIKACHU);
    assert.deepEqual(
      JSON.parse(localStorage.getItem(STORAGE_KEY)),
      favorites.items,
      'add() writes the current items to localStorage',
    );

    favorites.remove(25);
    assert.deepEqual(
      JSON.parse(localStorage.getItem(STORAGE_KEY)),
      [],
      'remove() writes the updated items to localStorage',
    );
  });

  test('loads existing favorites from localStorage on init', function (assert) {
    const stored = [
      { id: 1, name: 'bulbasaur', sprite: null, types: ['grass'] },
    ];
    localStorage.setItem(STORAGE_KEY, JSON.stringify(stored));

    const favorites = this.owner.lookup('service:favorites');

    assert.deepEqual(favorites.items, stored);
    assert.strictEqual(favorites.count, 1);
  });

  test('recovers gracefully when localStorage contains corrupted JSON', function (assert) {
    localStorage.setItem(STORAGE_KEY, '{not valid json');

    const favorites = this.owner.lookup('service:favorites');

    assert.deepEqual(
      favorites.items,
      [],
      'falls back to an empty list instead of throwing',
    );
  });
});
