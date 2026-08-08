import { module, test } from 'qunit';
import { visit, click, fillIn, currentURL, findAll } from '@ember/test-helpers';
import { setupApplicationTest } from 'pokedex-challenge/tests/helpers';
import StubPokeDataService from 'pokedex-challenge/tests/helpers/stub-poke-data';

module('Acceptance | list', function (hooks) {
  setupApplicationTest(hooks);

  hooks.beforeEach(function () {
    this.owner.register('service:poke-data', StubPokeDataService);
  });

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

  test('previous is disabled on the first page', async function (assert) {
    await visit('/');

    assert.dom('.page-status').hasText('Page 1 of 8');
    assert.dom('.pagination button:disabled').hasText('Previous');
  });

  test('next advances a page and previous comes back', async function (assert) {
    await visit('/');
    await click('.pagination a:last-of-type');

    assert.strictEqual(currentURL(), '/?page=2');
    assert.dom('.page-status').hasText('Page 2 of 8');
    assert.dom('.pokemon-card:nth-child(1) .pokemon-name').hasText('spearow');

    await click('.pagination a:first-of-type');

    assert.strictEqual(currentURL(), '/');
    assert.dom('.pokemon-card:nth-child(1) .pokemon-name').hasText('bulbasaur');
  });

  test('the last page is partial and next is disabled', async function (assert) {
    await visit('/?page=8');

    assert.strictEqual(
      findAll('.page > .pokemon-grid > .pokemon-card').length,
      11,
    );
    assert.dom('.pagination button:disabled').hasText('Next');
  });

  test('an out of range page clamps to the last page', async function (assert) {
    await visit('/?page=999');

    assert.dom('.page-status').hasText('Page 8 of 8');
  });

  test('search filters the current page', async function (assert) {
    await visit('/');
    await fillIn('.search-input', 'saur');

    assert.strictEqual(
      findAll('.page > .pokemon-grid > .pokemon-card').length,
      3,
    );
  });
});
