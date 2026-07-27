import { module, test } from 'qunit';
import { visit, findAll, click } from '@ember/test-helpers';
import { setupApplicationTest } from 'pokedex-challenge/tests/helpers';

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

  test('pagination advances to the next page and back', async function (assert) {
    await visit('/');

    assert.dom('.page-button:last-child').isNotDisabled('next is enabled');
    assert
      .dom('.page-button:first-child')
      .isDisabled('previous starts disabled');

    await click('.page-button:last-child');

    assert
      .dom('.pokemon-card:nth-child(1) .pokemon-name')
      .hasText('spearow', 'page 2 starts at pokemon #21');
    assert
      .dom('.page-button:first-child')
      .isNotDisabled('previous is now enabled');

    await click('.page-button:first-child');

    assert
      .dom('.pokemon-card:nth-child(1) .pokemon-name')
      .hasText('bulbasaur', 'previous returns to page 1');
  });
});
