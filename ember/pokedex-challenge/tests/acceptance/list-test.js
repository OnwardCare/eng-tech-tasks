import { module, test } from 'qunit';
import {
  visit,
  findAll,
  click,
  fillIn,
  find,
  settled,
} from '@ember/test-helpers';
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

  test('search finds a pokemon that is not on the current page', async function (assert) {
    await visit('/');

    // Pikachu is #25, well past the first page of 20.
    await fillIn('.search-input', 'pikachu');

    assert.strictEqual(findAll('.pokemon-card').length, 1);
    assert.dom('.pokemon-card .pokemon-name').hasText('pikachu');
  });

  test('search with no matches shows an empty state instead of a blank grid', async function (assert) {
    await visit('/');

    await fillIn('.search-input', 'not-a-real-pokemon');

    assert.strictEqual(findAll('.pokemon-card').length, 0);
    assert.dom('.empty-state').containsText('No Pokémon match');
  });

  test('rapid keystrokes are debounced to a single search for the final value', async function (assert) {
    await visit('/');

    // Dispatch native input events directly (bypassing the `fillIn` helper's
    // own settling) so every keystroke lands before the debounce timer for
    // the previous one has a chance to fire, the way a fast typist would.
    const input = find('.search-input');
    for (const partial of ['p', 'pi', 'pik', 'pika', 'pikachu']) {
      input.value = partial;
      input.dispatchEvent(new Event('input', { bubbles: true }));
    }
    await settled();

    assert.strictEqual(
      findAll('.pokemon-card').length,
      1,
      'only the final search term was ever applied',
    );
    assert.dom('.pokemon-card .pokemon-name').hasText('pikachu');
  });
});
