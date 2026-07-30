import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';

module('Unit | Service | favorites (array reactivity)', function (hooks) {
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

  // ===== Bug Fix: Array Reactivity Tests =====
  // These tests verify that @tracked items array properly notifies observers
  // when items are added or removed (array reassignment triggers tracking)

  test('items array is tracked and notifiable after add', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon = { id: 1, name: 'Bulbasaur' };

    // Verify items is tracked (should be an array)
    assert.ok(Array.isArray(service.items), 'items is an array');

    service.add(pokemon);

    // After add, items array should have changed reference (reassignment)
    // This allows tracking to detect the mutation
    assert.strictEqual(service.items.length, 1, 'items array has 1 element');
    assert.deepEqual(service.items[0], pokemon, 'item stored correctly');
  });

  test('items array reassigns after multiple adds', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon1 = { id: 1, name: 'Bulbasaur' };
    const pokemon2 = { id: 4, name: 'Charmander' };

    const initialArray = service.items;

    service.add(pokemon1);
    const afterFirstAdd = service.items;

    // Should be a different array reference after add
    assert.notStrictEqual(
      initialArray,
      afterFirstAdd,
      'array reference changed after first add',
    );

    service.add(pokemon2);
    const afterSecondAdd = service.items;

    // Should be a different array reference after second add
    assert.notStrictEqual(
      afterFirstAdd,
      afterSecondAdd,
      'array reference changed after second add',
    );

    assert.strictEqual(service.items.length, 2, 'array has 2 elements');
  });

  test('items array reassigns after remove', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon1 = { id: 1, name: 'Bulbasaur' };
    const pokemon2 = { id: 4, name: 'Charmander' };

    service.add(pokemon1);
    service.add(pokemon2);

    const beforeRemove = service.items;

    service.remove(1);

    const afterRemove = service.items;

    // Should be a different array reference after remove
    assert.notStrictEqual(
      beforeRemove,
      afterRemove,
      'array reference changed after remove',
    );

    assert.strictEqual(service.items.length, 1, 'array has 1 element after remove');
    assert.strictEqual(service.items[0].id, 4, 'remaining item is Charmander');
  });

  test('items array does not reassign if remove finds nothing', function (assert) {
    const service = this.owner.lookup('service:favorites');

    const beforeRemove = service.items;

    // Try to remove from empty set
    service.remove(999);

    const afterRemove = service.items;

    // Should be the same reference since nothing was removed
    assert.strictEqual(
      beforeRemove,
      afterRemove,
      'array reference unchanged when remove finds nothing',
    );
  });

  test('items array reassigns on toggle (add)', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon = { id: 1, name: 'Bulbasaur' };

    const beforeToggle = service.items;

    service.toggle(pokemon);

    const afterToggle = service.items;

    // Should be different reference after toggle add
    assert.notStrictEqual(
      beforeToggle,
      afterToggle,
      'array reference changed after toggle (add)',
    );

    assert.strictEqual(service.items.length, 1, 'array has 1 element');
  });

  test('items array reassigns on toggle (remove)', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon = { id: 1, name: 'Bulbasaur' };

    service.add(pokemon);
    const afterAdd = service.items;

    service.toggle(pokemon);

    const afterToggle = service.items;

    // Should be different reference after toggle remove
    assert.notStrictEqual(
      afterAdd,
      afterToggle,
      'array reference changed after toggle (remove)',
    );

    assert.strictEqual(service.items.length, 0, 'array is empty after toggle');
  });

  test('rapid array mutations maintain reference changes', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon = { id: 1, name: 'Bulbasaur' };

    const refs = [service.items];

    // Perform 5 operations
    service.add(pokemon);
    refs.push(service.items);

    service.remove(1);
    refs.push(service.items);

    service.add(pokemon);
    refs.push(service.items);

    service.remove(1);
    refs.push(service.items);

    service.add(pokemon);
    refs.push(service.items);

    // Each consecutive operation should have different reference
    for (let i = 0; i < refs.length - 1; i++) {
      assert.notStrictEqual(
        refs[i],
        refs[i + 1],
        `reference ${i} differs from reference ${i + 1}`,
      );
    }
  });

  test('tracked items property accessible and reactive', function (assert) {
    const service = this.owner.lookup('service:favorites');

    // Verify that items exists and is tracked
    assert.ok(service.items, 'items property exists');
    assert.ok(Array.isArray(service.items), 'items is an array');

    // Add and verify reactivity
    const pokemon = { id: 1, name: 'Bulbasaur' };
    service.add(pokemon);

    assert.strictEqual(service.count, 1, 'count reflects change');
    assert.true(service.isFavorite(1), 'isFavorite reflects change');
  });

  test('isFavorite getter works with array changes', function (assert) {
    const service = this.owner.lookup('service:favorites');
    const pokemon = { id: 1, name: 'Bulbasaur' };

    assert.false(service.isFavorite(1), 'not favorite initially');

    service.add(pokemon);
    assert.true(service.isFavorite(1), 'is favorite after add');

    service.remove(1);
    assert.false(service.isFavorite(1), 'not favorite after remove');
  });

  test('count getter reflects array mutations', function (assert) {
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

    service.remove(4);
    assert.strictEqual(service.count, 0, 'count is 0 after removing all');
  });
});
