import { module, test } from 'qunit';
import { visit, click, findAll } from '@ember/test-helpers';
import { setupApplicationTest } from 'pokedex-challenge/tests/helpers';
import StubPokeDataService from 'pokedex-challenge/tests/helpers/stub-poke-data';

module('Acceptance | favorites', function (hooks) {
  setupApplicationTest(hooks);

  hooks.beforeEach(function () {
    localStorage.clear();
    this.owner.register('service:poke-data', StubPokeDataService);
  });

  hooks.afterEach(function () {
    localStorage.clear();
  });

  test('starring from the list updates the nav count and the favorites route', async function (assert) {
    await visit('/');
    assert.dom('.nav-favorites').hasText('Favorites (0)');

    await click('.pokemon-card:nth-child(1) .favorite-button');
    assert.dom('.nav-favorites').hasText('Favorites (1)');

    await visit('/favorites');
    assert.strictEqual(findAll('.pokemon-card').length, 1);
    assert.dom('.pokemon-card .pokemon-name').hasText('bulbasaur');
  });

  test('favorites survive a fresh boot of the app', async function (assert) {
    localStorage.setItem(
      'pokedex:favorites',
      JSON.stringify([
        { id: 25, name: 'pikachu', sprite: '/sprites/25.png', types: [] },
      ]),
    );

    await visit('/favorites');

    assert.dom('.nav-favorites').hasText('Favorites (1)');
    assert.dom('.pokemon-card .pokemon-name').hasText('pikachu');
  });

  test('starring on the detail page renders a complete card in favorites', async function (assert) {
    await visit('/pokemon/25');
    await click('.favorite-button');

    await visit('/favorites');

    assert
      .dom('.pokemon-card .pokemon-sprite')
      .hasAttribute('src', '/sprites/25.png');
    assert.dom('.pokemon-card .type-badge').exists();
  });

  test('unstarring from the favorites route removes the card immediately', async function (assert) {
    await visit('/');
    await click('.pokemon-card:nth-child(1) .favorite-button');

    await visit('/favorites');
    await click('.pokemon-card .favorite-button');

    assert.dom('.empty-state').exists();
    assert.dom('.nav-favorites').hasText('Favorites (0)');
  });

  test('the star reflects state across routes', async function (assert) {
    await visit('/');
    await click('.pokemon-card:nth-child(1) .favorite-button');

    await visit('/pokemon/1');

    assert.dom('.favorite-button').hasAttribute('aria-pressed', 'true');
    assert
      .dom('.favorite-button')
      .hasAria('label', 'Remove bulbasaur from favorites');
  });
});
