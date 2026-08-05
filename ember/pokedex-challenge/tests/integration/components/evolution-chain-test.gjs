import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, find, findAll, waitUntil } from '@ember/test-helpers';
import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

function speciesRef(id, name) {
  return { name, url: `https://pokeapi.co/api/v2/pokemon-species/${id}/` };
}

function node(id, name, evolvesTo = []) {
  return { species: speciesRef(id, name), evolves_to: evolvesTo };
}

function stubChain(chain) {
  window.fetch = async () => ({ json: async () => ({ chain }) });
}

module('Integration | Component | evolution-chain', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.originalFetch = window.fetch;
  });

  hooks.afterEach(function () {
    window.fetch = this.originalFetch;
  });

  test('renders the evolution line in order and highlights the current stage', async function (assert) {
    stubChain(
      node(1, 'bulbasaur', [node(2, 'ivysaur', [node(3, 'venusaur')])]),
    );

    await render(
      <template>
        <EvolutionChain
          @evolutionChainUrl="https://pokeapi.co/api/v2/evolution-chain/1/"
          @currentId={{2}}
        />
      </template>,
    );
    await waitUntil(() => findAll('.evolution-stage').length === 3);

    const stages = findAll('.evolution-stage');
    assert.dom(stages[0]).hasText('bulbasaur').hasTagName('a');
    assert.dom(stages[0]).hasAttribute('href', '/pokemon/1');
    assert
      .dom(stages[1])
      .hasText('ivysaur')
      .hasClass('is-current')
      .hasTagName('span');
    assert.dom(stages[2]).hasText('venusaur').hasTagName('a');
    assert.dom(stages[2]).hasAttribute('href', '/pokemon/3');
    assert.strictEqual(findAll('.evolution-arrow').length, 2);
  });

  test('renders branching evolutions as siblings and locks stages outside gen 1', async function (assert) {
    stubChain(
      node(133, 'eevee', [
        node(134, 'vaporeon'),
        node(135, 'jolteon'),
        node(196, 'espeon'),
      ]),
    );

    await render(
      <template>
        <EvolutionChain
          @evolutionChainUrl="https://pokeapi.co/api/v2/evolution-chain/67/"
          @currentId={{133}}
        />
      </template>,
    );
    await waitUntil(() => findAll('.evolution-stage').length === 4);

    const levels = findAll('.evolution-level');
    assert.strictEqual(
      levels.length,
      2,
      'eevee and its evolutions form two levels',
    );
    assert.strictEqual(
      levels[1].querySelectorAll('.evolution-stage').length,
      3,
      'all three siblings render within the same level',
    );

    const espeon = findAll('.evolution-stage').find(
      (element) => element.textContent.trim() === 'espeon',
    );
    assert.dom(espeon).hasTagName('span').hasClass('evolution-stage-locked');
    assert.notOk(
      espeon.hasAttribute('href'),
      'out-of-range stage is not a link',
    );
    assert.ok(
      espeon.title.includes('outside Generation 1'),
      'tooltip explains why the stage is locked',
    );
  });

  test('shows an error message when the chain fails to load', async function (assert) {
    window.fetch = async () => {
      throw new Error('network down');
    };

    await render(
      <template>
        <EvolutionChain
          @evolutionChainUrl="https://pokeapi.co/api/v2/evolution-chain/1/"
          @currentId={{1}}
        />
      </template>,
    );
    await waitUntil(() => find('.evolution-error'));

    assert
      .dom('.evolution-error')
      .hasText("Couldn't load the evolution chain.");
  });
});
