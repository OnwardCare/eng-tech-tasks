import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { registerDestructor } from '@ember/destroyable';
import { LinkTo } from '@ember/routing';

export default class FeaturedRotator extends Component {
  @service pokeData;

  @tracked featured = null;

  constructor() {
    super(...arguments);
    this.loadFeatured();
    const intervalId = setInterval(() => {
      this.loadFeatured();
    }, 8000);
    registerDestructor(this, () => clearInterval(intervalId));
  }

  async loadFeatured() {
    const id = Math.floor(Math.random() * 151) + 1;
    const data = await this.pokeData.fetchPokemon(id);
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
