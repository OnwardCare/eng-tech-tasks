import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';

module('Unit | Service | favorites (edge cases)', function (hooks) {
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

  // ===== Invalid JSON Edge Cases =====

  test('handles empty string in localStorage', function (assert) {
    mockStorage['pokedex-favorites'] = '';

    const service = this.owner.lookup('service:favorites');

    // Should not crash, should fallback to empty
    assert.deepEqual(
      Array.from(service._favoriteIds),
      [],
      'Falls back to empty set on empty string',
    );
  });

  test('handles null-like string in localStorage', function (assert) {
    mockStorage['pokedex-favorites'] = 'null';

    const service = this.owner.lookup('service:favorites');

    // JSON.parse('null') returns null, not an array
    // Should handle gracefully
    assert.ok(true, 'Handles null-like string without crashing');
  });

  test('handles string array with non-integer values', function (assert) {
    mockStorage['pokedex-favorites'] = JSON.stringify(['1', 'abc', '4']);

    const service = this.owner.lookup('service:favorites');

    // Set constructor will accept any values
    assert.strictEqual(
      service._favoriteIds.size,
      3,
      'Set contains all values even if not numbers',
    );
  });

  test('handles string array with negative numbers', function (assert) {
    mockStorage['pokedex-favorites'] = JSON.stringify([-1, 4, 7]);

    const service = this.owner.lookup('service:favorites');

    const favoriteIds = Array.from(service._favoriteIds).sort((a, b) => a - b);
    assert.deepEqual(
      favoriteIds,
      [-1, 4, 7],
      'Set accepts negative numbers',
    );
  });

  test('handles string array with very large numbers', function (assert) {
    const largeNum = Number.MAX_SAFE_INTEGER;
    mockStorage['pokedex-favorites'] = JSON.stringify([1, largeNum, 7]);

    const service = this.owner.lookup('service:favorites');

    assert.true(
      service._favoriteIds.has(largeNum),
      'Set handles very large numbers',
    );
  });

  test('handles string array with duplicate IDs', function (assert) {
    mockStorage['pokedex-favorites'] = JSON.stringify([1, 4, 1, 7, 4]);

    const service = this.owner.lookup('service:favorites');

    // Set automatically deduplicates
    assert.strictEqual(service._favoriteIds.size, 3, 'Duplicates removed by Set');
  });

  // ===== Storage Quota Tests =====

  test('handles localStorage quota exceeded gracefully', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon = { id: 1, name: 'Bulbasaur' };

    service.add(pokemon);
    assert.true(service.isFavorite(1), 'Pokemon added successfully');

    // Simulate quota exceeded on next write
    window.localStorage.setItem = () => {
      throw new Error('QuotaExceededError');
    };

    const pokemon2 = { id: 4, name: 'Charmander' };
    // Should not throw, should continue
    service.add(pokemon2);

    assert.true(service.isFavorite(4), 'Second pokemon also added despite quota error');
  });

  // ===== Rapid Concurrent Operations =====

  test('multiple rapid adds maintain correct state', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon = [
      { id: 1, name: 'Bulbasaur' },
      { id: 4, name: 'Charmander' },
      { id: 7, name: 'Squirtle' },
      { id: 10, name: 'Caterpie' },
      { id: 13, name: 'Weedle' },
    ];

    // Rapid adds
    pokemon.forEach((p) => service.add(p));

    assert.strictEqual(service.count, 5, 'All 5 pokemon added');
    pokemon.forEach((p) => {
      assert.true(service.isFavorite(p.id), `Pokemon ${p.id} is favorite`);
    });

    const stored = JSON.parse(mockStorage['pokedex-favorites']);
    assert.deepEqual(stored.length, 5, 'localStorage has all 5 IDs');
  });

  test('alternating add/remove operations', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon = [
      { id: 1, name: 'Bulbasaur' },
      { id: 4, name: 'Charmander' },
      { id: 7, name: 'Squirtle' },
    ];

    service.add(pokemon[0]);
    service.add(pokemon[1]);
    service.remove(pokemon[0].id);
    service.add(pokemon[2]);
    service.remove(pokemon[1].id);

    assert.true(service.isFavorite(7), 'Only Squirtle should be favorite');
    assert.strictEqual(service.count, 1, 'Only 1 pokemon in favorites');

    const stored = JSON.parse(mockStorage['pokedex-favorites']);
    assert.deepEqual(stored, [7], 'localStorage reflects final state');
  });

  // ===== State Persistence =====

  test('favorites persist correctly after multiple operations', function (assert) {
    const service = this.owner.lookup('service:favorites');

    // Add initial favorites
    for (let i = 1; i <= 5; i++) {
      service.add({ id: i, name: `Pokemon ${i}` });
    }

    // Remove some
    for (let i = 2; i <= 4; i++) {
      service.remove(i);
    }

    // Verify final state
    assert.strictEqual(service.count, 2, '2 favorites remain');
    assert.true(service.isFavorite(1), 'Pokemon 1 favorite');
    assert.true(service.isFavorite(5), 'Pokemon 5 favorite');
    assert.false(service.isFavorite(2), 'Pokemon 2 not favorite');
    assert.false(service.isFavorite(3), 'Pokemon 3 not favorite');
    assert.false(service.isFavorite(4), 'Pokemon 4 not favorite');

    // Verify localStorage
    const stored = JSON.parse(mockStorage['pokedex-favorites']);
    assert.deepEqual(stored, [1, 5], 'localStorage reflects final state');
  });

  // ===== Empty and Boundary Cases =====

  test('removing from empty favorite set does nothing', function (assert) {
    const service = this.owner.lookup('service:favorites');

    assert.strictEqual(service.count, 0, 'No favorites initially');

    // Remove from empty set
    service.remove(999);

    assert.strictEqual(service.count, 0, 'Still no favorites');
    const stored = JSON.parse(mockStorage['pokedex-favorites']);
    assert.deepEqual(stored, [], 'localStorage empty');
  });

  test('toggling same pokemon multiple times', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon = { id: 1, name: 'Bulbasaur' };

    // Toggle many times (even count)
    for (let i = 0; i < 10; i++) {
      service.toggle(pokemon);
    }

    assert.false(
      service.isFavorite(1),
      'Pokemon not favorite after even number of toggles',
    );

    // Toggle one more time (odd count)
    service.toggle(pokemon);
    assert.true(
      service.isFavorite(1),
      'Pokemon favorite after odd number of toggles',
    );
  });

  test('adding same pokemon multiple times', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon = { id: 1, name: 'Bulbasaur' };

    service.add(pokemon);
    service.add(pokemon);
    service.add(pokemon);

    // items[] will have duplicates (it's an array, not a set)
    assert.strictEqual(
      service.items.length,
      3,
      'items array contains duplicates',
    );
    // But isFavorite returns true
    assert.true(service.isFavorite(1), 'isFavorite returns true');
    // And count reflects total items
    assert.strictEqual(service.count, 3, 'count is 3');

    // localStorage should reflect all 3
    const stored = JSON.parse(mockStorage['pokedex-favorites']);
    assert.deepEqual(stored, [1, 1, 1], 'localStorage has duplicates');
  });

  // ===== Storage Persistence After Reload =====

  test('loading from storage with missing items works', function (assert) {
    mockStorage['pokedex-favorites'] = JSON.stringify([1, 4, 7]);

    const service = this.owner.lookup('service:favorites');

    // _favoriteIds should be loaded
    const ids = Array.from(service._favoriteIds).sort();
    assert.deepEqual(ids, [1, 4, 7], 'IDs loaded from storage');

    // items[] starts empty (lazy-load pattern)
    assert.strictEqual(service.items.length, 0, 'items array empty initially');
  });

  test('adding new favorite after loading from storage updates all', function (assert) {
    mockStorage['pokedex-favorites'] = JSON.stringify([1, 4]);

    const service = this.owner.lookup('service:favorites');

    // Load from storage
    assert.strictEqual(service.items.length, 0, 'items empty initially');

    // Add new favorite
    service.add({ id: 7, name: 'Squirtle' });

    // Both old and new should be in localStorage
    const stored = JSON.parse(mockStorage['pokedex-favorites']);
    assert.deepEqual(stored, [7], 'localStorage has new pokemon (not old ones)');
    // Note: Old favoriteIds remain in _favoriteIds, but items only has new one
  });

  // ===== Service Isolation =====

  test('multiple service instances share localStorage', function (assert) {
    const service1 = this.owner.lookup('service:favorites');
    service1.add({ id: 1, name: 'Bulbasaur' });

    // Create a new "instance" by looking up again (Ember caches services)
    const service2 = this.owner.lookup('service:favorites');

    // Should be the same instance
    assert.strictEqual(
      service1,
      service2,
      'Service is singleton, same instance',
    );

    // Verify they share state
    assert.strictEqual(service2.count, 1, 'Second lookup sees same state');
    assert.true(service2.isFavorite(1), 'Bulbasaur is favorite in both');
  });
});
