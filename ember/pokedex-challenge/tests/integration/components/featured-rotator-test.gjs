import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, find, waitUntil, clearRender } from '@ember/test-helpers';
import FeaturedRotator from 'pokedex-challenge/components/featured-rotator';

module('Integration | Component | featured-rotator', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.originalFetch = window.fetch;
    window.fetch = async () => ({
      json: async () => ({
        id: 25,
        name: 'pikachu',
        sprites: {
          other: {
            'official-artwork': {
              front_default: 'https://example.com/pikachu.png',
            },
          },
        },
      }),
    });
  });

  hooks.afterEach(function () {
    window.fetch = this.originalFetch;
  });

  test('renders the featured pokemon once the fetch resolves', async function (assert) {
    await render(<template><FeaturedRotator /></template>);
    await waitUntil(() => find('.featured-name'));

    assert.dom('.featured-name').hasText('pikachu');
    assert
      .dom('.featured-sprite')
      .hasAttribute('src', 'https://example.com/pikachu.png');
  });

  test('clears its rotation interval when destroyed', async function (assert) {
    const originalClearInterval = window.clearInterval;
    const clearedIds = [];
    window.clearInterval = (id) => {
      clearedIds.push(id);
      return originalClearInterval(id);
    };

    try {
      await render(<template><FeaturedRotator /></template>);
      await waitUntil(() => find('.featured-name'));

      await clearRender();

      assert.strictEqual(
        clearedIds.length,
        1,
        'clearInterval was called exactly once on teardown',
      );
    } finally {
      window.clearInterval = originalClearInterval;
    }
  });
});
