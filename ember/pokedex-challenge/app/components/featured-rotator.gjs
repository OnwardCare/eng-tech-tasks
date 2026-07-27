import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { LinkTo } from '@ember/routing';
import { registerDestructor } from '@ember/destroyable';

export default class FeaturedRotator extends Component {
  @service pokeData;
  @tracked featured = null;

  constructor() {
    super(...arguments);
    this.loadFeatured();

    const interval = setInterval(() => {
      this.loadFeatured();
    }, 8000);

    // Clear the interval when the component is torn down to avoid memory leaks
    registerDestructor(this, () => clearInterval(interval));
  }

  async loadFeatured() {
    const id = Math.floor(Math.random() * 151) + 1;
    // Use the service so this request benefits from the shared cache
    const data = await this.pokeData.fetchPokemon(id);
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
