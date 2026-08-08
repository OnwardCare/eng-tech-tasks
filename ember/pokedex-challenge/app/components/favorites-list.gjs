import Component from '@glimmer/component';
import { service } from '@ember/service';
import PokemonCard from 'pokedex-challenge/components/pokemon-card';

export default class FavoritesList extends Component {
  @service favorites;

  <template>
    {{#if this.favorites.count}}
      <div class="pokemon-grid">
        {{#each this.favorites.items key="id" as |pokemon|}}
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
