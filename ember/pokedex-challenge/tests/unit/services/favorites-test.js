import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';

module('Unit | Service | favorites', function (hooks) {
  setupTest(hooks);

  let mockStorage;

  hooks.beforeEach(function () {
    // Mock localStorage
    mockStorage = {};

    window.localStorage = {
      getItem: (key) => mockStorage[key] || null,
      setItem: (key, value) => {
        mockStorage[key] = value;
      },
      removeItem: (key) => {
        delete mockStorage[key];
      },
      clear: () => {
        mockStorage = {};
      },
    };
  });

  // ===== Basic Functionality Tests =====

  test('it can add and toggle favorites', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon = { id: 1, name: 'Bulbasaur' };

    assert.false(service.isFavorite(1), 'Bulbasaur not favorite initially');
    assert.strictEqual(service.count, 0, 'count is 0 initially');

    service.add(pokemon);
    assert.true(service.isFavorite(1), 'Bulbasaur is favorite after add');
    assert.strictEqual(service.count, 1, 'count is 1 after add');

    service.remove(1);
    assert.false(service.isFavorite(1), 'Bulbasaur not favorite after remove');
    assert.strictEqual(service.count, 0, 'count is 0 after remove');
  });

  test('it can toggle a favorite', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon = { id: 1, name: 'Bulbasaur' };

    assert.false(service.isFavorite(1), 'Bulbasaur not favorite initially');

    service.toggle(pokemon);
    assert.true(service.isFavorite(1), 'Bulbasaur is favorite after toggle');

    service.toggle(pokemon);
    assert.false(
      service.isFavorite(1),
      'Bulbasaur not favorite after second toggle',
    );
  });

  test('count reflects number of items', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon1 = { id: 1, name: 'Bulbasaur' };
    const pokemon2 = { id: 4, name: 'Charmander' };

    assert.strictEqual(service.count, 0, 'count is 0 initially');

    service.add(pokemon1);
    assert.strictEqual(service.count, 1, 'count is 1 after add');

    service.add(pokemon2);
    assert.strictEqual(service.count, 2, 'count is 2 after second add');

    service.remove(1);
    assert.strictEqual(service.count, 1, 'count is 1 after remove');
  });

  // ===== localStorage Sync Tests =====

  test('it syncs to localStorage on add', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon1 = { id: 1, name: 'Bulbasaur' };
    const pokemon2 = { id: 4, name: 'Charmander' };

    service.add(pokemon1);
    let stored = JSON.parse(mockStorage['pokedex-favorites']);
    assert.deepEqual(stored, [1], 'localStorage has ID 1 after first add');

    service.add(pokemon2);
    stored = JSON.parse(mockStorage['pokedex-favorites']);
    assert.deepEqual(stored, [1, 4], 'localStorage has IDs 1 and 4');
  });

  test('it syncs to localStorage on remove', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon1 = { id: 1, name: 'Bulbasaur' };
    const pokemon2 = { id: 4, name: 'Charmander' };

    service.add(pokemon1);
    service.add(pokemon2);

    let stored = JSON.parse(mockStorage['pokedex-favorites']);
    assert.deepEqual(stored, [1, 4], 'localStorage has IDs 1 and 4');

    service.remove(1);

    stored = JSON.parse(mockStorage['pokedex-favorites']);
    assert.deepEqual(stored, [4], 'localStorage has only ID 4 after remove');
  });

  test('it syncs to localStorage on toggle', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon = { id: 1, name: 'Bulbasaur' };

    service.toggle(pokemon);
    let stored = JSON.parse(mockStorage['pokedex-favorites']);
    assert.deepEqual(stored, [1], 'localStorage has ID 1 after toggle');

    service.toggle(pokemon);
    stored = JSON.parse(mockStorage['pokedex-favorites']);
    assert.deepEqual(stored, [], 'localStorage empty after second toggle');
  });

  // ===== localStorage Load Tests =====

  test('it loads favorites from localStorage on init', function (assert) {
    // Pre-populate localStorage before service is created
    mockStorage['pokedex-favorites'] = JSON.stringify([1, 4, 7]);

    const service = this.owner.lookup('service:favorites');

    // _favoriteIds should be populated with loaded IDs
    const favoriteIds = Array.from(service._favoriteIds).sort();
    assert.deepEqual(
      favoriteIds,
      [1, 4, 7],
      'Favorite IDs loaded from localStorage',
    );
  });

  test('it handles empty localStorage gracefully', function (assert) {
    const service = this.owner.lookup('service:favorites');

    assert.deepEqual(
      Array.from(service._favoriteIds),
      [],
      'Empty set when no data in localStorage',
    );
    assert.strictEqual(service.count, 0, 'count is 0');
  });

  // ===== Error Handling Tests =====

  test('it handles invalid JSON in localStorage gracefully', function (assert) {
    mockStorage['pokedex-favorites'] = 'invalid json {]';

    const service = this.owner.lookup('service:favorites');

    assert.deepEqual(
      Array.from(service._favoriteIds),
      [],
      'Falls back to empty set on invalid JSON',
    );
  });

  test('it handles malformed JSON (not an array) gracefully', function (assert) {
    mockStorage['pokedex-favorites'] = JSON.stringify({ favorites: [1, 4] });

    const service = this.owner.lookup('service:favorites');

    // Should not throw, and should handle gracefully
    assert.ok(true, 'No exception thrown when parsing malformed JSON');
  });

  test('it handles localStorage unavailable gracefully', function (assert) {
    window.localStorage = {
      getItem: () => {
        throw new Error('localStorage is not available');
      },
      setItem: () => {
        throw new Error('localStorage is not available');
      },
    };

    const service = this.owner.lookup('service:favorites');
    const pokemon = { id: 1, name: 'Bulbasaur' };

    // Should not throw
    service.add(pokemon);
    assert.true(
      service.isFavorite(1),
      'Favorite still works in-memory when localStorage unavailable',
    );
    assert.strictEqual(service.count, 1, 'count is correct');
  });

  test('it detects localStorage unavailability on initialization', function (assert) {
    window.localStorage = {
      setItem: () => {
        throw new Error('localStorage is not available');
      },
      getItem: () => {
        throw new Error('localStorage is not available');
      },
    };

    const service = this.owner.lookup('service:favorites');

    assert.false(
      service._localStorageAvailable,
      'localStorage marked as unavailable',
    );
  });

  // ===== Rapid Operations Tests =====

  test('rapid add/remove operations result in correct state', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon = { id: 1, name: 'Bulbasaur' };

    service.add(pokemon);
    service.remove(1);
    service.add(pokemon);
    service.remove(1);
    service.add(pokemon);

    assert.true(
      service.isFavorite(1),
      'Favorite state correct after rapid operations',
    );
    assert.strictEqual(service.count, 1, 'count is 1');

    const stored = JSON.parse(mockStorage['pokedex-favorites']);
    assert.deepEqual(stored, [1], 'localStorage reflects final state');
  });

  test('multiple pokemon with rapid toggles maintain correct state', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const p1 = { id: 1, name: 'Bulbasaur' };
    const p2 = { id: 4, name: 'Charmander' };
    const p3 = { id: 7, name: 'Squirtle' };

    service.toggle(p1);
    service.toggle(p2);
    service.toggle(p1); // Remove p1
    service.toggle(p3);
    service.toggle(p2); // Remove p2

    assert.true(service.isFavorite(7), 'Squirtle is favorite');
    assert.false(service.isFavorite(1), 'Bulbasaur is not favorite');
    assert.false(service.isFavorite(4), 'Charmander is not favorite');

    const stored = JSON.parse(mockStorage['pokedex-favorites']);
    assert.deepEqual(stored, [7], 'localStorage has only Squirtle');
  });

  // ===== Multiple Pokemon Tests =====

  test('add multiple pokemon to favorites', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon = [
      { id: 1, name: 'Bulbasaur' },
      { id: 4, name: 'Charmander' },
      { id: 7, name: 'Squirtle' },
    ];

    pokemon.forEach((p) => service.add(p));

    assert.strictEqual(service.count, 3, 'count is 3');
    pokemon.forEach((p) => {
      assert.true(service.isFavorite(p.id), `${p.name} is favorite`);
    });

    const stored = JSON.parse(mockStorage['pokedex-favorites']);
    assert.deepEqual(stored, [1, 4, 7], 'localStorage has all IDs');
  });
});
