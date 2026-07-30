import { module, test } from 'qunit';
import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
import { render, clearRender } from '@ember/test-helpers';
import FeaturedRotator from 'pokedex-challenge/components/featured-rotator';

module('Integration | Component | featured-rotator', function (hooks) {
  setupRenderingTest(hooks);

  test('clears its rotation interval when destroyed', async function (assert) {
    const originalSetInterval = window.setInterval;
    const originalClearInterval = window.clearInterval;
    let scheduledId;
    let clearedId;

    window.setInterval = (...args) => {
      scheduledId = originalSetInterval(...args);
      return scheduledId;
    };
    window.clearInterval = (id) => {
      clearedId = id;
      return originalClearInterval(id);
    };

    try {
      await render(<template><FeaturedRotator /></template>);
      await clearRender();

      assert.ok(scheduledId, 'an interval was scheduled on render');
      assert.strictEqual(
        clearedId,
        scheduledId,
        'the same interval was cleared when the component was destroyed',
      );
    } finally {
      window.setInterval = originalSetInterval;
      window.clearInterval = originalClearInterval;
    }
  });
});
