import { pageTitle } from 'ember-page-title';
import PokemonCard from 'pokedex-challenge/components/pokemon-card';
import { service } from '@ember/service';
import Component from '@glimmer/component';

export default class FavoritesTemplate extends Component {
  @service favorites;

  <template>
    {{pageTitle "Favorites"}}

    <h1>Favorites</h1>

    {{#if this.favorites.items.length}}
      <div class="pokemon-grid">
        {{#each this.favorites.items as |pokemon|}}
          <PokemonCard @pokemon={{pokemon}} />
        {{/each}}
      </div>
    {{else}}
      <p class="empty-state">
        No favorites yet. Star some Pokémon and they will show up here.
      </p>
    {{/if}}
  </template>
}
