import { module, test } from 'qunit';
import { setupTest } from 'pokedex-challenge/tests/helpers';

module('Unit | Service | list-state', function (hooks) {
  setupTest(hooks);

  test('stores offset and searchTerm', function (assert) {
    const listState = this.owner.lookup('service:list-state');

    assert.strictEqual(listState.offset, 0);
    assert.strictEqual(listState.searchTerm, '');

    listState.offset = 40;
    listState.searchTerm = 'pika';

    assert.strictEqual(listState.offset, 40);
    assert.strictEqual(listState.searchTerm, 'pika');
  });
});
