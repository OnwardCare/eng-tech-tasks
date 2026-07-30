import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, click, settled } from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import FavoriteButton from 'pokedex-challenge/components/favorite-button';

const bulbasaur = { id: 1, name: 'bulbasaur' };
const ivysaur = { id: 2, name: 'ivysaur' };

module('Integration | Component | favorite-button', function (hooks) {
  setupRenderingTest(hooks);

  test('renders unfavorited state by default', async function (assert) {
    await render(
      <template><FavoriteButton @pokemon={{bulbasaur}} /></template>,
    );

    assert.dom('.favorite-button').hasText('☆');
    assert.dom('.favorite-button').doesNotHaveClass('is-favorite');
  });

  test('renders favorited state when the pokemon is already a favorite', async function (assert) {
    const favorites = this.owner.lookup('service:favorites');
    favorites.add(bulbasaur);

    await render(
      <template><FavoriteButton @pokemon={{bulbasaur}} /></template>,
    );

    assert.dom('.favorite-button').hasText('★');
    assert.dom('.favorite-button').hasClass('is-favorite');
  });

  test('clicking toggles favorite state', async function (assert) {
    await render(
      <template><FavoriteButton @pokemon={{bulbasaur}} /></template>,
    );

    assert.dom('.favorite-button').hasText('☆');

    await click('.favorite-button');
    assert.dom('.favorite-button').hasText('★');

    await click('.favorite-button');
    assert.dom('.favorite-button').hasText('☆');
  });

  test('re-syncs favorite state when @pokemon changes (STORY-04 regression)', async function (assert) {
    const favorites = this.owner.lookup('service:favorites');
    favorites.add(ivysaur);

    class State {
      @tracked pokemon = bulbasaur;
    }
    const state = new State();

    await render(
      <template><FavoriteButton @pokemon={{state.pokemon}} /></template>,
    );
    assert.dom('.favorite-button').hasText('☆', 'bulbasaur is not a favorite');

    // Simulate navigating from bulbasaur's detail page to ivysaur's,
    // which reuses the same FavoriteButton component instance rather
    // than destroying and recreating it.
    state.pokemon = ivysaur;
    await settled();

    assert
      .dom('.favorite-button')
      .hasText('★', 'star re-syncs to ivysaur, which is a favorite');
  });
});
