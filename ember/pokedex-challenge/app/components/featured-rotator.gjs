import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { LinkTo } from '@ember/routing';

const GEN_1_COUNT = 151;
const ROTATE_EVERY = 8000;

export default class FeaturedRotator extends Component {
  @service pokeData;

  @tracked featured = null;

  #timer;

  constructor() {
    super(...arguments);
    this.loadFeatured();
    this.#timer = setInterval(() => this.loadFeatured(), ROTATE_EVERY);
  }

  willDestroy() {
    clearInterval(this.#timer);
    super.willDestroy(...arguments);
  }

  async loadFeatured() {
    const id = Math.floor(Math.random() * GEN_1_COUNT) + 1;

    try {
      const data = await this.pokeData.fetchPokemon(id);

      if (this.isDestroying || this.isDestroyed) {
        return;
      }

      this.featured = {
        id: data.id,
        name: data.name,
        sprite: data.sprites.other['official-artwork'].front_default,
      };
    } catch {
      // A failed rotation just leaves the current pokemon in place.
    }
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
