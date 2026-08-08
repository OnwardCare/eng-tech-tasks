import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { LinkTo } from '@ember/routing';
import { GEN_1_COUNT } from 'pokedex-challenge/services/poke-data';

const ROTATE_INTERVAL = 8000;

export default class FeaturedRotator extends Component {
  @service pokeData;

  @tracked featured = null;

  #timer = null;

  constructor() {
    super(...arguments);
    this.loadFeatured();
    this.#timer = setInterval(() => this.loadFeatured(), ROTATE_INTERVAL);
  }

  willDestroy() {
    super.willDestroy(...arguments);
    clearInterval(this.#timer);
  }

  async loadFeatured() {
    const id = Math.floor(Math.random() * GEN_1_COUNT) + 1;

    try {
      const pokemon = await this.pokeData.fetchPokemon(id);

      if (!this.isDestroyed) {
        this.featured = pokemon;
      }
    } catch {
      // A failed rotation is not worth surfacing; the next tick retries.
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
            src={{this.featured.artwork}}
            alt={{this.featured.name}}
            class="featured-sprite"
          />
          <span class="featured-name">{{this.featured.name}}</span>
        </LinkTo>
      {{/if}}
    </div>
  </template>
}
