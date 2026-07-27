import Component from '@glimmer/component';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';

export default class FavoriteButton extends Component {
  @service favorites;

  // Derive state from the service — avoids local state that can drift out of sync
  get isFavorite() {
    return this.favorites.isFavorite(this.args.pokemon.id);
  }

  @action
  toggle() {
    this.favorites.toggle(this.args.pokemon);
  }

  <template>
    <button
      type="button"
      class="favorite-button {{if this.isFavorite 'is-favorite'}}"
      aria-label="Toggle favorite"
      {{on "click" this.toggle}}
    >
      {{if this.isFavorite "★" "☆"}}
    </button>
  </template>
}
