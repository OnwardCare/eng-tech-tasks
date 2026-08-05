import { module, test } from 'qunit';
import { visit } from '@ember/test-helpers';
import { setupApplicationTest } from 'pokedex-challenge/tests/helpers';

module('Acceptance | error handling', function (hooks) {
  setupApplicationTest(hooks);

  test('shows the error template when the index route fails to load', async function (assert) {
    const originalFetch = window.fetch;
    window.fetch = async () => {
      throw new Error('network down');
    };

    try {
      await visit('/');
    } finally {
      window.fetch = originalFetch;
    }

    assert
      .dom('.status-message')
      .hasText('Something went wrong loading this page. Please try again.');
  });
});
