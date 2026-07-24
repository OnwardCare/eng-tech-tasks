import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, click, findAll } from '@ember/test-helpers';
import FavoriteButton from 'pokedex-challenge/components/favorite-button';

const PIKACHU = { id: 25, name: 'pikachu', sprite: '/25.png', types: [] };

module('Integration | Component | favorite-button', function (hooks) {
  setupRenderingTest(hooks);

  test('toggles the favorite and reflects it in the button', async function (assert) {
    const favorites = this.owner.lookup('service:favorites');

    await render(<template><FavoriteButton @pokemon={{PIKACHU}} /></template>);

    assert.dom('button').hasAttribute('aria-pressed', 'false');
    assert.dom('button').hasText('☆');

    await click('button');

    assert.dom('button').hasClass('is-favorite');
    assert.dom('button').hasAttribute('aria-pressed', 'true');
    assert.dom('button').hasText('★');
    assert.true(favorites.isFavorite(25));

    await click('button');

    assert.dom('button').doesNotHaveClass('is-favorite');
    assert.false(favorites.isFavorite(25));
  });

  test('starts from the persisted state', async function (assert) {
    this.owner.lookup('service:favorites').add(PIKACHU);

    await render(<template><FavoriteButton @pokemon={{PIKACHU}} /></template>);

    assert.dom('button').hasClass('is-favorite');
  });

  test('every star for the same pokemon stays in sync', async function (assert) {
    await render(
      <template>
        <FavoriteButton @pokemon={{PIKACHU}} />
        <FavoriteButton @pokemon={{PIKACHU}} />
      </template>,
    );

    await click(findAll('button')[0]);

    assert.strictEqual(
      findAll('button.is-favorite').length,
      2,
      'the other star updated too',
    );
  });
});
