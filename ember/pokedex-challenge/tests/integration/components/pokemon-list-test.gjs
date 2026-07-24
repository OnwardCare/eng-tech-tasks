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

function page(offset, limit) {
  return Array.from({ length: limit }, (_, index) => card(offset + index + 1));
}

class StubPokeData extends Service {
  requestedOffsets = [];

  fetchPage(offset, limit) {
    this.requestedOffsets.push(offset);
    return Promise.resolve(page(offset, limit));
  }
}

const FIRST_PAGE = page(0, PAGE_SIZE);

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

  test('a page is only fetched once', async function (assert) {
    await render(<template><PokemonList @pokemon={{FIRST_PAGE}} /></template>);

    await click('.page-button:last-of-type');
    await click('.page-button:first-of-type');
    await click('.page-button:last-of-type');

    assert.deepEqual(
      this.owner.lookup('service:poke-data').requestedOffsets,
      [PAGE_SIZE],
      'page 1 comes from the route, page 2 is cached after the first visit',
    );
  });

  test('sorting does not disturb the page it was given', async function (assert) {
    const pokemon = [card(3), card(1), card(2)];

    await render(<template><PokemonList @pokemon={{pokemon}} /></template>);

    assert.deepEqual(renderedIds(), ['#1', '#2', '#3'], 'sorted for display');
    assert.deepEqual(
      pokemon.map((p) => p.id),
      [3, 1, 2],
      'the array passed in is left alone',
    );
  });

  test('search filters the current page', async function (assert) {
    await render(<template><PokemonList @pokemon={{FIRST_PAGE}} /></template>);

    await fillIn('.search-input', 'pokemon-1');

    assert.deepEqual(renderedIds(), [
      '#1',
      '#10',
      '#11',
      '#12',
      '#13',
      '#14',
      '#15',
      '#16',
      '#17',
      '#18',
      '#19',
    ]);
  });
});
