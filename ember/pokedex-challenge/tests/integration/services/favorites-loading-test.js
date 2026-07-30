import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';

module('Integration | Service | favorites loading', function (hooks) {
  setupTest(hooks);

  let mockStorage;
  let mockPokeData;

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

    // Mock poke-data service
    mockPokeData = {
      fetchPokemon: (id) => {
        const pokemon = {
          1: { id: 1, name: 'Bulbasaur' },
          4: { id: 4, name: 'Charmander' },
          7: { id: 7, name: 'Squirtle' },
          999: null, // Non-existent
        };
        return Promise.resolve(pokemon[id]);
      },
    };

    // Register the mock service
    this.owner.register('service:poke-data', {
      create: () => mockPokeData,
    });
  });

  // ===== Favorites Loading Tests =====

  test('favorites are loaded from localStorage on app init', function (assert) {
    // Pre-populate localStorage with favorite IDs
    mockStorage['pokedex-favorites'] = JSON.stringify([1, 4, 7]);

    const service = this.owner.lookup('service:favorites');

    // loadFromLocalStorage() should have been called in constructor
    const favoriteIds = Array.from(service._favoriteIds).sort();
    assert.deepEqual(
      favoriteIds,
      [1, 4, 7],
      'Favorite IDs loaded from localStorage on init',
    );
  });

  // ===== Preload Tests =====

  test('preloadFavoritesIfNeeded fetches full pokemon objects', async function (assert) {
    const service = this.owner.lookup('service:favorites');
    service._favoriteIds = new Set([1, 4]);

    await service.preloadFavoritesIfNeeded();

    assert.strictEqual(service.items.length, 2, 'Two pokemon loaded');
    assert.strictEqual(service.items[0].id, 1, 'Bulbasaur loaded');
    assert.strictEqual(service.items[1].id, 4, 'Charmander loaded');
  });

  test('preloadFavoritesIfNeeded skips missing pokemon', async function (assert) {
    const service = this.owner.lookup('service:favorites');
    service._favoriteIds = new Set([1, 999, 4]); // 999 doesn't exist

    await service.preloadFavoritesIfNeeded();

    // Only 2 pokemon should load (1 and 4; 999 returns null)
    assert.strictEqual(service.items.length, 2, 'Only valid pokemon loaded');
    assert.ok(
      service.items.every((p) => [1, 4].includes(p.id)),
      'Only pokemon 1 and 4 are loaded',
    );
  });

  test('preloadFavoritesIfNeeded does not re-fetch already-loaded pokemon', async function (assert) {
    const service = this.owner.lookup('service:favorites');
    service._favoriteIds = new Set([1, 4]);
    service.items = [{ id: 1, name: 'Bulbasaur' }]; // Already loaded

    let fetchCount = 0;
    mockPokeData.fetchPokemon = (id) => {
      fetchCount++;
      const pokemon = {
        4: { id: 4, name: 'Charmander' },
      };
      return Promise.resolve(pokemon[id]);
    };

    await service.preloadFavoritesIfNeeded();

    assert.strictEqual(fetchCount, 1, 'Only fetched 1 missing pokemon');
    assert.strictEqual(service.items.length, 2, 'Total 2 pokemon');
  });

  test('preloadFavoritesIfNeeded returns early if all pokemon already loaded', async function (assert) {
    const service = this.owner.lookup('service:favorites');
    service._favoriteIds = new Set([1, 4]);
    service.items = [
      { id: 1, name: 'Bulbasaur' },
      { id: 4, name: 'Charmander' },
    ];

    let fetchCount = 0;
    mockPokeData.fetchPokemon = () => {
      fetchCount++;
      return Promise.resolve(null);
    };

    await service.preloadFavoritesIfNeeded();

    assert.strictEqual(fetchCount, 0, 'No fetches when all pokemon loaded');
  });

  test('handles errors during pokemon fetch gracefully', async function (assert) {
    const service = this.owner.lookup('service:favorites');
    service._favoriteIds = new Set([1, 4]);

    let fetchCallCount = 0;
    mockPokeData.fetchPokemon = (id) => {
      fetchCallCount++;
      if (id === 1) {
        return Promise.resolve({ id: 1, name: 'Bulbasaur' });
      } else {
        return Promise.reject(new Error('Network error'));
      }
    };

    // Should not throw
    await service.preloadFavoritesIfNeeded();

    assert.strictEqual(fetchCallCount, 2, 'Attempted to fetch both pokemon');
    assert.strictEqual(service.items.length, 1, 'Only successfully fetched pokemon loaded');
    assert.strictEqual(service.items[0].id, 1, 'Bulbasaur loaded despite Charmander error');
  });

  // ===== End-to-End Tests =====

  test('end-to-end: star, simulate reload, verify favorites loaded', async function (assert) {
    // Create a service instance and add favorites
    const service = this.owner.lookup('service:favorites');
    const p1 = { id: 1, name: 'Bulbasaur' };
    const p2 = { id: 4, name: 'Charmander' };

    service.add(p1);
    service.add(p2);

    // Simulate reload: clear items, reload from localStorage
    service.items = [];
    service.loadFromLocalStorage();

    // Pre-load favorites (as would happen on /favorites route entry)
    await service.preloadFavoritesIfNeeded();

    assert.strictEqual(service.items.length, 2, 'Two pokemon loaded after reload');
    assert.true(service.isFavorite(1), 'Bulbasaur is favorite');
    assert.true(service.isFavorite(4), 'Charmander is favorite');
  });

  test('preloadFavoritesIfNeeded with empty favorite set', async function (assert) {
    const service = this.owner.lookup('service:favorites');
    service._favoriteIds = new Set(); // No favorites

    let fetchCount = 0;
    mockPokeData.fetchPokemon = () => {
      fetchCount++;
      return Promise.resolve(null);
    };

    await service.preloadFavoritesIfNeeded();

    assert.strictEqual(fetchCount, 0, 'No fetches when favorite set is empty');
    assert.strictEqual(service.items.length, 0, 'No items loaded');
  });
});
