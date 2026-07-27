import { module, test } from 'qunit';
import { setupTest } from 'pokedex-challenge/tests/helpers';

module('Unit | Service | favorites', function (hooks) {
  setupTest(hooks);

  hooks.beforeEach(function () {
    // Clear localStorage before each test to avoid state leakage
    localStorage.removeItem('pokedex-favorites');
  });

  test('it starts empty when localStorage has no data', function (assert) {
    const service = this.owner.lookup('service:favorites');
    assert.strictEqual(service.count, 0);
  });

  test('add() stores a pokemon and updates count', function (assert) {
    const service = this.owner.lookup('service:favorites');
    service.add({ id: 1, name: 'bulbasaur' });
    assert.strictEqual(service.count, 1);
    assert.true(service.isFavorite(1));
  });

  test('remove() removes a pokemon by id', function (assert) {
    const service = this.owner.lookup('service:favorites');
    service.add({ id: 1, name: 'bulbasaur' });
    service.remove(1);
    assert.strictEqual(service.count, 0);
    assert.false(service.isFavorite(1));
  });

  test('toggle() adds when not a favorite and removes when it is', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon = { id: 1, name: 'bulbasaur' };
    service.toggle(pokemon);
    assert.true(service.isFavorite(1));
    service.toggle(pokemon);
    assert.false(service.isFavorite(1));
  });

  test('favorites are persisted in localStorage', function (assert) {
    const service = this.owner.lookup('service:favorites');
    service.add({ id: 4, name: 'charmander' });

    const stored = JSON.parse(localStorage.getItem('pokedex-favorites'));
    assert.deepEqual(stored, [{ id: 4, name: 'charmander' }]);
  });

  test('it loads persisted favorites from localStorage on init', function (assert) {
    // Pre-seed localStorage before the service is looked up
    localStorage.setItem(
      'pokedex-favorites',
      JSON.stringify([{ id: 7, name: 'squirtle' }]),
    );

    const service = this.owner.lookup('service:favorites');
    assert.true(service.isFavorite(7));
    assert.strictEqual(service.count, 1);
  });
});
