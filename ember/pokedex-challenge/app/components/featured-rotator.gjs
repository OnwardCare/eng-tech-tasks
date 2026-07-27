import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { LinkTo } from '@ember/routing';

const ROTATE_INTERVAL_MS = 8000;
const GEN_1_COUNT = 151;

export default class FeaturedRotator extends Component {
  @service pokeData;

  @tracked featured = null;

  #intervalId;

  constructor() {
    super(...arguments);
    this.loadFeatured();
    this.#intervalId = setInterval(() => {
      this.loadFeatured();
    }, ROTATE_INTERVAL_MS);
  }

  willDestroy() {
    super.willDestroy(...arguments);
    clearInterval(this.#intervalId);
  }

  async loadFeatured() {
    const id = Math.floor(Math.random() * GEN_1_COUNT) + 1;
    const data = await this.pokeData.fetchPokemon(id);

    // The interval keeps firing on a timer independent of the component's
    // lifecycle; without this guard a tick that resolves after the
    // component is torn down would set tracked state on a dead component.
    if (this.isDestroying || this.isDestroyed) {
      return;
    }

    this.featured = {
      id: data.id,
      name: data.name,
      sprite: data.sprites.other['official-artwork'].front_default,
    };
  }

  <template>
    <div class="featured-rotator">
      {{#if this.featured}}
        <span class="featured-label">Featured Pokémon</span>
        <LinkTo
          @route="pokemon"
          @model={{this.featured.id}}
          class="featured-link"
        >
          <img
            src={{this.featured.sprite}}
            alt={{this.featured.name}}
            class="featured-sprite"
          />
          <span class="featured-name">{{this.featured.name}}</span>
        </LinkTo>
      {{/if}}
    </div>
  </template>
}
