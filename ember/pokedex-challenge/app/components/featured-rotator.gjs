import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { LinkTo } from '@ember/routing';
import { GEN_1_COUNT } from 'pokedex-challenge/utils/pokeapi';

const ROTATE_INTERVAL_MS = 8000;

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
    try {
      const data = await this.pokeData.fetchPokemon(id);
      this.featured = {
        id: data.id,
        name: data.name,
        sprite: data.sprites.other['official-artwork'].front_default,
      };
    } catch {
      // Decorative widget: skip this rotation and retry on the next tick
      // rather than surfacing an error for a non-critical banner.
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
