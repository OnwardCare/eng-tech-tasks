import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import { modifier } from 'ember-modifier';

export default class FavoriteButton extends Component {
  @service favorites;

  @tracked isFavorite;

  // Glimmer component constructors only run once per component instance.
  // Ember reuses the same FavoriteButton instance when navigating between
  // /pokemon/:id routes, so syncing isFavorite in the constructor would
  // leave the previous Pokémon's favorite state showing. This functional
  // modifier re-runs whenever @pokemon changes, keeping the star in sync.
  syncOnPokemonChange = modifier((element, [pokemon]) => {
    this.isFavorite = this.favorites.isFavorite(pokemon.id);
  });

  @action
  toggle() {
    this.favorites.toggle(this.args.pokemon);
    this.isFavorite = !this.isFavorite;
  }

  <template>
    <button
      type="button"
      class="favorite-button {{if this.isFavorite 'is-favorite'}}"
      aria-label="Toggle favorite"
      {{on "click" this.toggle}}
      {{this.syncOnPokemonChange @pokemon}}
    >
      {{if this.isFavorite "★" "☆"}}
    </button>
  </template>
}
