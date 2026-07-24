import { module, test } from 'qunit';
import { visit, click, findAll } from '@ember/test-helpers';
import { setupApplicationTest } from 'pokedex-challenge/tests/helpers';

function firstCardName() {
  return findAll('.pokemon-card .pokemon-name')[0]?.textContent.trim();
}

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

  test('Next and Previous page through the pokedex', async function (assert) {
    await visit('/');

    assert.strictEqual(firstCardName(), 'bulbasaur');
    assert
      .dom('.page-button:first-of-type')
      .isDisabled('nothing before page 1');

    await click('.page-button:last-of-type');

    assert.strictEqual(firstCardName(), 'spearow', 'page 2 starts at #21');
    assert.dom('.page-indicator').hasText('Page 2 of 8');

    await click('.page-button:first-of-type');

    assert.strictEqual(firstCardName(), 'bulbasaur', 'Previous goes back');
    assert.dom('.page-indicator').hasText('Page 1 of 8');
    assert.strictEqual(findAll('.pokemon-card').length, 20);
  });
});
