import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';

module('Integration | Service | favorites sprite/types transformation', function (hooks) {
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

    // Mock poke-data service with full API responses
    mockPokeData = {
      fetchPokemon: (id) => {
        const pokemonData = {
          1: {
            id: 1,
            name: 'bulbasaur',
            sprites: {
              front_default:
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/pokemon/1.png',
              other: {
                'official-artwork': {
                  front_default:
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/pokemon/other/official-artwork/1.png',
                },
              },
            },
            types: [
              { type: { name: 'grass' } },
              { type: { name: 'poison' } },
            ],
          },
          4: {
            id: 4,
            name: 'charmander',
            sprites: {
              front_default:
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/pokemon/4.png',
              other: {
                'official-artwork': {
                  front_default:
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/pokemon/other/official-artwork/4.png',
                },
              },
            },
            types: [{ type: { name: 'fire' } }],
          },
          7: {
            id: 7,
            name: 'squirtle',
            sprites: {
              front_default:
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/pokemon/7.png',
              other: {
                'official-artwork': {
                  front_default:
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/pokemon/other/official-artwork/7.png',
                },
              },
            },
            types: [{ type: { name: 'water' } }],
          },
          999: null, // Non-existent
        };
        return Promise.resolve(pokemonData[id]);
      },
    };

    // Register the mock service
    this.owner.register('service:poke-data', {
      create: () => mockPokeData,
    });
  });

  // ===== Bug Fix: Sprite/Types Transformation Tests =====
  // These tests verify that preloadFavoritesIfNeeded() transforms API response
  // to include sprite and types fields expected by pokemon-card component

  test('preloadFavoritesIfNeeded transforms sprite from API data', async function (assert) {
    const service = this.owner.lookup('service:favorites');
    service._favoriteIds = new Set([1]);

    await service.preloadFavoritesIfNeeded();

    assert.strictEqual(service.items.length, 1, 'One pokemon loaded');
    const pokemon = service.items[0];

    assert.strictEqual(
      pokemon.sprite,
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/pokemon/1.png',
      'sprite extracted from sprites.front_default',
    );
    assert.ok(pokemon.sprite, 'sprite property exists and has value');
  });

  test('preloadFavoritesIfNeeded transforms types from API data', async function (assert) {
    const service = this.owner.lookup('service:favorites');
    service._favoriteIds = new Set([1]);

    await service.preloadFavoritesIfNeeded();

    assert.strictEqual(service.items.length, 1, 'One pokemon loaded');
    const pokemon = service.items[0];

    assert.deepEqual(
      pokemon.types,
      ['grass', 'poison'],
      'types extracted and mapped correctly',
    );
    assert.ok(Array.isArray(pokemon.types), 'types is an array');
  });

  test('preloadFavoritesIfNeeded creates pokemon-card compatible object', async function (assert) {
    const service = this.owner.lookup('service:favorites');
    service._favoriteIds = new Set([4]);

    await service.preloadFavoritesIfNeeded();

    const pokemon = service.items[0];

    // Verify all fields expected by pokemon-card template
    assert.strictEqual(pokemon.id, 4, 'id field present');
    assert.strictEqual(pokemon.name, 'charmander', 'name field present');
    assert.ok(pokemon.sprite, 'sprite field present');
    assert.ok(Array.isArray(pokemon.types), 'types field present as array');
  });

  test('preloadFavoritesIfNeeded handles single-type pokemon', async function (assert) {
    const service = this.owner.lookup('service:favorites');
    service._favoriteIds = new Set([4]); // Charmander has 1 type

    await service.preloadFavoritesIfNeeded();

    const pokemon = service.items[0];

    assert.deepEqual(
      pokemon.types,
      ['fire'],
      'single type extracted correctly',
    );
  });

  test('preloadFavoritesIfNeeded handles multi-type pokemon', async function (assert) {
    const service = this.owner.lookup('service:favorites');
    service._favoriteIds = new Set([1]); // Bulbasaur has 2 types

    await service.preloadFavoritesIfNeeded();

    const pokemon = service.items[0];

    assert.deepEqual(
      pokemon.types,
      ['grass', 'poison'],
      'multiple types extracted correctly',
    );
    assert.strictEqual(pokemon.types.length, 2, 'types array has correct length');
  });

  test('preloadFavoritesIfNeeded loads multiple pokemon with correct sprites', async function (assert) {
    const service = this.owner.lookup('service:favorites');
    service._favoriteIds = new Set([1, 4, 7]);

    await service.preloadFavoritesIfNeeded();

    assert.strictEqual(service.items.length, 3, 'Three pokemon loaded');

    // Verify each has correct sprite
    const bulbasaur = service.items.find((p) => p.id === 1);
    const charmander = service.items.find((p) => p.id === 4);
    const squirtle = service.items.find((p) => p.id === 7);

    assert.ok(bulbasaur.sprite, 'Bulbasaur has sprite');
    assert.ok(charmander.sprite, 'Charmander has sprite');
    assert.ok(squirtle.sprite, 'Squirtle has sprite');

    // Verify each has types array
    assert.ok(Array.isArray(bulbasaur.types), 'Bulbasaur has types array');
    assert.ok(Array.isArray(charmander.types), 'Charmander has types array');
    assert.ok(Array.isArray(squirtle.types), 'Squirtle has types array');
  });

  test('preloadFavoritesIfNeeded handles API data with null sprites gracefully', async function (assert) {
    const service = this.owner.lookup('service:favorites');

    // Mock null sprite scenario
    mockPokeData.fetchPokemon = (id) => {
      if (id === 1) {
        return Promise.resolve({
          id: 1,
          name: 'bulbasaur',
          sprites: { front_default: null }, // null sprite
          types: [{ type: { name: 'grass' } }],
        });
      }
      return Promise.resolve(null);
    };

    service._favoriteIds = new Set([1]);

    await service.preloadFavoritesIfNeeded();

    const pokemon = service.items[0];
    assert.strictEqual(pokemon.sprite, null, 'null sprite handled');
  });

  test('preloadFavoritesIfNeeded preserves id and name', async function (assert) {
    const service = this.owner.lookup('service:favorites');
    service._favoriteIds = new Set([1, 4]);

    await service.preloadFavoritesIfNeeded();

    const bulbasaur = service.items.find((p) => p.id === 1);
    const charmander = service.items.find((p) => p.id === 4);

    assert.strictEqual(bulbasaur.id, 1, 'Bulbasaur id preserved');
    assert.strictEqual(bulbasaur.name, 'bulbasaur', 'Bulbasaur name preserved');
    assert.strictEqual(charmander.id, 4, 'Charmander id preserved');
    assert.strictEqual(charmander.name, 'charmander', 'Charmander name preserved');
  });

  test('preloadFavoritesIfNeeded skips extra API fields', async function (assert) {
    const service = this.owner.lookup('service:favorites');
    service._favoriteIds = new Set([1]);

    await service.preloadFavoritesIfNeeded();

    const pokemon = service.items[0];

    // Verify only expected fields exist
    const allowedFields = ['id', 'name', 'sprite', 'types'];
    const actualFields = Object.keys(pokemon);

    actualFields.forEach((field) => {
      assert.ok(
        allowedFields.includes(field),
        `field '${field}' is in allowed list`,
      );
    });
  });

  test('end-to-end: /favorites route can display card with sprites and types', async function (assert) {
    const service = this.owner.lookup('service:favorites');

    // Simulate user starred pokemon
    mockStorage['pokedex-favorites'] = JSON.stringify([1, 4]);

    // Reinitialize service to load from storage
    service.loadFromLocalStorage();

    // Preload (as route would do)
    await service.preloadFavoritesIfNeeded();

    // Verify both pokemon are loaded with complete data
    assert.strictEqual(service.items.length, 2, 'Two pokemon loaded');

    const bulbasaur = service.items.find((p) => p.id === 1);
    const charmander = service.items.find((p) => p.id === 4);

    // All fields needed by pokemon-card are present
    assert.ok(bulbasaur.id, 'Bulbasaur has id');
    assert.ok(bulbasaur.name, 'Bulbasaur has name');
    assert.ok(bulbasaur.sprite, 'Bulbasaur has sprite');
    assert.ok(Array.isArray(bulbasaur.types), 'Bulbasaur has types');

    assert.ok(charmander.id, 'Charmander has id');
    assert.ok(charmander.name, 'Charmander has name');
    assert.ok(charmander.sprite, 'Charmander has sprite');
    assert.ok(Array.isArray(charmander.types), 'Charmander has types');
  });
});
