import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { LinkTo } from '@ember/routing';

export default class FeaturedRotator extends Component {
  @tracked featured = null;
  #intervalId = null;

  constructor() {
    super(...arguments);
    this.loadFeatured();
    this.#intervalId = setInterval(() => {
      this.loadFeatured();
    }, 8000);
  }

  willDestroy() {
    super.willDestroy();
    clearInterval(this.#intervalId);
  }

  async loadFeatured() {
    const id = Math.floor(Math.random() * 151) + 1;
    const response = await fetch(`https://pokeapi.co/api/v2/pokemon/${id}`);
    const data = await response.json();
    if (this.isDestroying || this.isDestroyed) return;
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
