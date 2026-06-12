import { module, test } from 'qunit';
import { visit, findAll } from '@ember/test-helpers';
import { setupApplicationTest } from 'ember-qunit';

module('Acceptance | list', function (hooks) {
  setupApplicationTest(hooks);

  test('the index page shows the pokemon grid', async function (assert) {
    await visit('/');

    assert.strictEqual(
      findAll('.page > .pokemon-grid > .pokemon-card').length,
      20,
    );
    assert
      .dom(
        '.page > .pokemon-grid > .pokemon-card:nth-child(1) .pokemon-link h3.pokemon-name',
      )
      .hasText('bulbasaur');
  });
});
