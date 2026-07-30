import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click } from '@ember/test-helpers';
import { hbs } from 'ember-cli-htmlbars';

module('Integration | Component | favorite-button', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders with empty star initially', async function (assert) {
    const pokemon = { id: 1, name: 'Bulbasaur' };
    this.pokemon = pokemon;

    await render(hbs`<FavoriteButton @pokemon={{this.pokemon}} />`);

    assert.dom('[data-test-favorite-button]').hasText('☆', 'Empty star rendered');
    assert
      .dom('[data-test-favorite-button]')
      .doesNotHaveClass('is-favorite', 'No is-favorite class initially');
  });

  test('it toggles favorite state on click', async function (assert) {
    const pokemon = { id: 1, name: 'Bulbasaur' };
    this.pokemon = pokemon;

    const service = this.owner.lookup('service:favorites');

    await render(hbs`<FavoriteButton @pokemon={{this.pokemon}} />`);

    // Initially empty
    assert.dom('[data-test-favorite-button]').hasText('☆');
    assert.false(
      service.isFavorite(1),
      'Service shows not favorite initially',
    );

    // Click to star
    await click('[data-test-favorite-button]');

    // Should be filled
    assert.dom('[data-test-favorite-button]').hasText('★', 'Filled star after click');
    assert
      .dom('[data-test-favorite-button]')
      .hasClass('is-favorite', 'is-favorite class added');
    assert.true(service.isFavorite(1), 'Service shows favorite after click');

    // Click to unstar
    await click('[data-test-favorite-button]');

    // Should be empty again
    assert.dom('[data-test-favorite-button]').hasText('☆', 'Empty star after second click');
    assert
      .dom('[data-test-favorite-button]')
      .doesNotHaveClass('is-favorite', 'is-favorite class removed');
    assert.false(service.isFavorite(1), 'Service shows not favorite after unstar');
  });

  test('it updates when pokemon prop changes', async function (assert) {
    const pokemon1 = { id: 1, name: 'Bulbasaur' };
    const pokemon2 = { id: 4, name: 'Charmander' };
    this.pokemon = pokemon1;

    const service = this.owner.lookup('service:favorites');

    // Star pokemon1
    service.add(pokemon1);

    await render(hbs`<FavoriteButton @pokemon={{this.pokemon}} />`);

    assert.dom('[data-test-favorite-button]').hasText('★', 'Shows filled star for p1');

    // Change pokemon to pokemon2
    this.set('pokemon', pokemon2);

    assert.dom('[data-test-favorite-button]').hasText('☆', 'Shows empty star for p2');

    // Star pokemon2
    service.add(pokemon2);

    assert.dom('[data-test-favorite-button]').hasText('★', 'Shows filled star for p2 after add');

    // Change back to pokemon1
    this.set('pokemon', pokemon1);

    assert.dom('[data-test-favorite-button]').hasText('★', 'Shows filled star again for p1');
  });

  test('it responds to service state changes immediately', async function (assert) {
    const pokemon = { id: 1, name: 'Bulbasaur' };
    this.pokemon = pokemon;

    const service = this.owner.lookup('service:favorites');

    await render(hbs`<FavoriteButton @pokemon={{this.pokemon}} />`);

    // Star via service (not button)
    service.add(pokemon);

    // Component should update immediately due to tracked items
    assert
      .dom('[data-test-favorite-button]')
      .hasText('★', 'Button shows filled star after service add');

    // Unstar via service
    service.remove(1);

    // Component should update immediately
    assert
      .dom('[data-test-favorite-button]')
      .hasText('☆', 'Button shows empty star after service remove');
  });

  test('it handles rapid clicks correctly', async function (assert) {
    const pokemon = { id: 1, name: 'Bulbasaur' };
    this.pokemon = pokemon;

    const service = this.owner.lookup('service:favorites');

    await render(hbs`<FavoriteButton @pokemon={{this.pokemon}} />`);

    // Rapid clicks: 5 times (should end up starred)
    for (let i = 0; i < 5; i++) {
      await click('[data-test-favorite-button]');
    }

    // After odd number of clicks, should be starred
    assert.dom('[data-test-favorite-button]').hasText('★', 'Starred after 5 clicks');
    assert.true(service.isFavorite(1), 'Service confirms favorite');
  });

  test('button has correct aria-label', async function (assert) {
    const pokemon = { id: 1, name: 'Bulbasaur' };
    this.pokemon = pokemon;

    await render(hbs`<FavoriteButton @pokemon={{this.pokemon}} />`);

    assert.dom('[data-test-favorite-button]').hasAttribute(
      'aria-label',
      'Toggle favorite',
      'Button has accessible label',
    );
  });

  test('button is a button element', async function (assert) {
    const pokemon = { id: 1, name: 'Bulbasaur' };
    this.pokemon = pokemon;

    await render(hbs`<FavoriteButton @pokemon={{this.pokemon}} />`);

    assert.dom('[data-test-favorite-button]').hasAttribute(
      'type',
      'button',
      'Element is a button',
    );
  });

  test('component stays in sync with service across multiple instances', async function (assert) {
    const pokemon1 = { id: 1, name: 'Bulbasaur' };
    const pokemon2 = { id: 4, name: 'Charmander' };
    this.pokemon1 = pokemon1;
    this.pokemon2 = pokemon2;

    const service = this.owner.lookup('service:favorites');

    await render(hbs`
      <FavoriteButton @pokemon={{this.pokemon1}} />
      <FavoriteButton @pokemon={{this.pokemon2}} />
    `);

    const buttons = Array.from(document.querySelectorAll('[data-test-favorite-button]'));

    // Both should be empty initially
    assert.dom(buttons[0]).hasText('☆', 'First button empty');
    assert.dom(buttons[1]).hasText('☆', 'Second button empty');

    // Star pokemon1 via service
    service.add(pokemon1);

    // First button should update immediately
    assert.dom(buttons[0]).hasText('★', 'First button filled after add');
    assert.dom(buttons[1]).hasText('☆', 'Second button still empty');

    // Star pokemon2
    service.add(pokemon2);

    // Both buttons should now be filled
    assert.dom(buttons[0]).hasText('★', 'First button still filled');
    assert.dom(buttons[1]).hasText('★', 'Second button now filled');
  });
});
