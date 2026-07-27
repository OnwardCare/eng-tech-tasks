import { module, test } from 'qunit';
import { setupTest } from 'pokedex-challenge/tests/helpers';

module('Unit | Service | poke-data', function (hooks) {
  setupTest(hooks);
  
  let originalFetch;

  hooks.beforeEach(function() {
    originalFetch = window.fetch;
  });

  hooks.afterEach(function() {
    window.fetch = originalFetch;
  });

  test('it caches fetchPokemon calls', async function (assert) {
    let service = this.owner.lookup('service:poke-data');
    let fetchCount = 0;
    
    window.fetch = async function() {
      fetchCount++;
      return {
        json: async () => ({ id: 1, name: 'bulbasaur' })
      };
    };

    await service.fetchPokemon(1);
    await service.fetchPokemon(1);
    
    assert.strictEqual(fetchCount, 1, 'fetch is called only once for the same id');
  });

  test('it caches fetchSpecies calls', async function (assert) {
    let service = this.owner.lookup('service:poke-data');
    let fetchCount = 0;
    
    window.fetch = async function() {
      fetchCount++;
      return {
        json: async () => ({ id: 1, name: 'bulbasaur species' })
      };
    };

    await service.fetchSpecies(1);
    await service.fetchSpecies(1);
    
    assert.strictEqual(fetchCount, 1, 'fetch is called only once for the same id');
  });
});
