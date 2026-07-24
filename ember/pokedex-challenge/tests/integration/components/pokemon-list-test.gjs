import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, click, fillIn, findAll } from '@ember/test-helpers';
import Service from '@ember/service';
import PokemonList, {
  PAGE_SIZE,
} from 'pokedex-challenge/components/pokemon-list';

const GEN_1_COUNT = 151;

function card(id) {
  return { id, name: `pokemon-${id}`, sprite: `/${id}.png`, types: [] };
}

const INDEX = Array.from({ length: GEN_1_COUNT }, (_, i) => ({
  id: i + 1,
  name: `pokemon-${i + 1}`,
}));

const FIRST_PAGE = INDEX.slice(0, PAGE_SIZE).map((entry) => card(entry.id));

class StubPokeData extends Service {
  cardRequests = [];

  fetchIndex() {
    return Promise.resolve(INDEX);
  }

  fetchCards(ids) {
    this.cardRequests.push(ids);
    return Promise.resolve(ids.map(card));
  }
}

function renderedIds() {
  return findAll('.pokemon-card .pokemon-id').map((el) =>
    el.textContent.trim(),
  );
}

module('Integration | Component | pokemon-list', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.owner.register('service:poke-data', StubPokeData);
    this.owner.setupRouter();
  });

  test('paging forward and back returns to the previous page', async function (assert) {
    await render(<template><PokemonList @pokemon={{FIRST_PAGE}} /></template>);

    assert.strictEqual(renderedIds()[0], '#1');
    assert.dom('.page-indicator').hasText('Page 1 of 8');

    await click('.page-button:last-of-type');

    assert.strictEqual(renderedIds()[0], '#21', 'page 2 starts at 21');
    assert.dom('.page-indicator').hasText('Page 2 of 8');

    await click('.page-button:first-of-type');

    assert.strictEqual(renderedIds()[0], '#1', 'back on page 1');
    assert.dom('.page-indicator').hasText('Page 1 of 8');

    await click('.page-button:last-of-type');

    assert.strictEqual(renderedIds()[0], '#21', 'and forward again');
  });

  test('previous is disabled on the first page, next on the last', async function (assert) {
    await render(<template><PokemonList @pokemon={{FIRST_PAGE}} /></template>);

    assert.dom('.page-button:first-of-type').isDisabled();
    assert.dom('.page-button:last-of-type').isNotDisabled();

    for (let offset = PAGE_SIZE; offset < GEN_1_COUNT; offset += PAGE_SIZE) {
      await click('.page-button:last-of-type');
    }

    assert.dom('.page-indicator').hasText('Page 8 of 8');
    assert.dom('.page-button:last-of-type').isDisabled();
    assert.dom('.page-button:first-of-type').isNotDisabled();
    assert.strictEqual(
      renderedIds().length,
      GEN_1_COUNT % PAGE_SIZE,
      'the last page is short',
    );
  });

  test('a page is only loaded once', async function (assert) {
    await render(<template><PokemonList @pokemon={{FIRST_PAGE}} /></template>);

    await click('.page-button:last-of-type');
    await click('.page-button:first-of-type');
    await click('.page-button:last-of-type');

    assert.strictEqual(
      this.owner.lookup('service:poke-data').cardRequests.length,
      1,
      'page 1 comes from the route, page 2 is reused once loaded',
    );
  });

  test('search finds pokemon that are not on the current page', async function (assert) {
    await render(<template><PokemonList @pokemon={{FIRST_PAGE}} /></template>);

    await fillIn('.search-input', 'pokemon-133');

    assert.deepEqual(renderedIds(), ['#133'], 'found without paging to it');
    assert.dom('.pagination').doesNotExist('a single page needs no controls');
  });

  test('search is case-insensitive and trimmed', async function (assert) {
    await render(<template><PokemonList @pokemon={{FIRST_PAGE}} /></template>);

    await fillIn('.search-input', '  POKEMON-25 ');

    assert.deepEqual(renderedIds(), ['#25']);
  });

  test('search results paginate when there are too many for one page', async function (assert) {
    await render(<template><PokemonList @pokemon={{FIRST_PAGE}} /></template>);

    await fillIn('.search-input', 'pokemon-1');

    assert.strictEqual(renderedIds().length, PAGE_SIZE);
    assert.deepEqual(renderedIds().slice(0, 2), ['#1', '#10']);
    assert.dom('.page-indicator').hasText('Page 1 of 4');

    await click('.page-button:last-of-type');

    // Page 1 of the matches is #1, #10-#19, then #100-#108.
    assert.strictEqual(renderedIds()[0], '#109', 'the second page of matches');
    assert.dom('.page-indicator').hasText('Page 2 of 4');
  });

  test('a search with no matches says so', async function (assert) {
    await render(<template><PokemonList @pokemon={{FIRST_PAGE}} /></template>);

    await fillIn('.search-input', 'mewthree');

    assert.dom('.empty-state').hasText('No Pokémon match "mewthree".');
    assert.dom('.pokemon-grid').doesNotExist();
    assert.dom('.pagination').doesNotExist();
  });

  test('clearing the search returns to the full list', async function (assert) {
    await render(<template><PokemonList @pokemon={{FIRST_PAGE}} /></template>);

    await fillIn('.search-input', 'pokemon-133');
    await fillIn('.search-input', '');

    assert.strictEqual(renderedIds().length, PAGE_SIZE);
    assert.strictEqual(renderedIds()[0], '#1');
    assert.dom('.page-indicator').hasText('Page 1 of 8');
  });

  test('sorting orders the whole dex, not just the visible page', async function (assert) {
    await render(<template><PokemonList @pokemon={{FIRST_PAGE}} /></template>);

    await fillIn('.sort-select', 'name');

    assert.deepEqual(renderedIds().slice(0, 3), ['#1', '#10', '#100']);
    assert.dom('.page-indicator').hasText('Page 1 of 8');
  });

  test('the array of pokemon passed in is left alone', async function (assert) {
    const pokemon = [card(3), card(1), card(2)];

    await render(<template><PokemonList @pokemon={{pokemon}} /></template>);

    assert.deepEqual(renderedIds(), ['#1', '#2', '#3'], 'sorted for display');
    assert.deepEqual(
      pokemon.map((p) => p.id),
      [3, 1, 2],
      'without touching the route model',
    );
  });
});
