import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled } from '@ember/test-helpers';
import { hbs } from 'ember-cli-htmlbars';

module('Unit | Service | favorites', function (hooks) {
  setupRenderingTest(hooks);

  test('count updates after add()', async function (assert) {
    const service = this.owner.lookup('service:favorites');
    this.set('favorites', service);

    await render(hbs`<span id="count">{{this.favorites.count}}</span>`);
    assert.dom('#count').hasText('0');

    service.add({ id: 25, name: 'pikachu' });
    await settled();

    assert.dom('#count').hasText('1');
  });
});
