import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { LinkTo } from '@ember/routing';
import { registerDestructor } from '@ember/destroyable';
import { API_POKEMON_LIMIT } from 'pokedex-challenge/services/poke-data';

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
    try {
      const id = Math.floor(Math.random() * API_POKEMON_LIMIT) + 1;
      const data = await this.pokeData.fetchPokemon(id);
      this.featured = {
        id: data.id,
        name: data.name,
        sprite: data.sprites.other['official-artwork'].front_default,
      };
    } catch {
      // Keep the previously featured Pokémon if a refresh fails
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
