import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, click } from '@ember/test-helpers';
import FavoriteButton from 'pokedex-challenge/components/favorite-button';

const STORAGE_KEY = 'pokedex:favorites';

module('Integration | Component | favorite-button', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    localStorage.removeItem(STORAGE_KEY);
  });

  test('toggling one instance updates every other instance for the same pokemon', async function (assert) {
    const pokemon = { id: 25, name: 'pikachu' };

    await render(
      <template>
        <div id="card-a"><FavoriteButton @pokemon={{pokemon}} /></div>
        <div id="card-b"><FavoriteButton @pokemon={{pokemon}} /></div>
      </template>,
    );

    assert.dom('#card-a button').doesNotHaveClass('is-favorite');
    assert.dom('#card-b button').doesNotHaveClass('is-favorite');

    await click('#card-a button');

    assert.dom('#card-a button').hasClass('is-favorite');
    assert
      .dom('#card-b button')
      .hasClass('is-favorite', 'second instance picks up the change too');

    await click('#card-b button');

    assert
      .dom('#card-a button')
      .doesNotHaveClass('is-favorite', 'unfavoriting anywhere clears both');
  });
});
