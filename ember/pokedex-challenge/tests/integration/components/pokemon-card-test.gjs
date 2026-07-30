import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render } from '@ember/test-helpers';
import PokemonCard from 'pokedex-challenge/components/pokemon-card';

const PIKACHU = {
  id: 25,
  name: 'pikachu',
  sprite: 'pikachu.png',
  types: ['electric'],
};

module('Integration | Component | pokemon-card', function (hooks) {
  setupRenderingTest(hooks);

  test('hides id, types, and favorite button when simplified', async function (assert) {
    await render(
      <template>
        <PokemonCard @pokemon={{PIKACHU}} @simplified={{true}} />
      </template>,
    );

    assert.dom('.pokemon-name').hasText('pikachu');
    assert.dom('.favorite-button').doesNotExist();
    assert.dom('.pokemon-id').doesNotExist();
    assert.dom('.pokemon-types').doesNotExist();
  });

  test('shows id, types, and favorite button by default', async function (assert) {
    await render(<template><PokemonCard @pokemon={{PIKACHU}} /></template>);

    assert.dom('.favorite-button').exists();
    assert.dom('.pokemon-id').hasText('#25');
    assert.dom('.pokemon-types').exists();
  });
});
