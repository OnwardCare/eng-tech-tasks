import { module, test } from 'qunit';
import { visit, click } from '@ember/test-helpers';
import { setupApplicationTest } from 'pokedex-challenge/tests/helpers';
import { STORAGE_KEY } from 'pokedex-challenge/services/favorites';

const PIKACHU = {
  id: 25,
  name: 'pikachu',
  sprite: '/25.png',
  types: ['electric'],
};

module('Acceptance | favorites', function (hooks) {
  setupApplicationTest(hooks);

  test('starring a pokemon updates the nav, the star and /favorites at once', async function (assert) {
    await visit('/');
    assert.dom('.nav-favorites').hasText('Favorites (0)');

    await click('.pokemon-card:first-child .favorite-button');

    assert.dom('.nav-favorites').hasText('Favorites (1)');
    assert
      .dom('.pokemon-card:first-child .favorite-button')
      .hasClass('is-favorite');

    await visit('/favorites');

    assert.dom('.pokemon-grid .pokemon-card').exists({ count: 1 });
    assert.dom('.pokemon-card .pokemon-name').hasText('bulbasaur');

    await click('.pokemon-card .favorite-button');

    assert.dom('.pokemon-grid .pokemon-card').doesNotExist();
    assert.dom('.empty-state').exists();
    assert.dom('.nav-favorites').hasText('Favorites (0)');
  });

  test('favorites survive a reload', async function (assert) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify([PIKACHU]));

    await visit('/favorites');

    assert.dom('.nav-favorites').hasText('Favorites (1)');
    assert.dom('.pokemon-card .pokemon-name').hasText('pikachu');
    assert.dom('.pokemon-card .favorite-button').hasClass('is-favorite');
  });

  test('a star set elsewhere is already filled in on the grid', async function (assert) {
    localStorage.setItem(
      STORAGE_KEY,
      JSON.stringify([
        { id: 1, name: 'bulbasaur', sprite: '/1.png', types: [] },
      ]),
    );

    await visit('/');

    assert.dom('.nav-favorites').hasText('Favorites (1)');
    assert
      .dom('.pokemon-card:first-child .favorite-button')
      .hasClass('is-favorite');
  });
});
