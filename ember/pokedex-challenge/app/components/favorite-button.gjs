import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';

export default class FavoriteButton extends Component {
  @service favorites;

  @tracked isFavorite;

  constructor() {
    super(...arguments);
    this.isFavorite = this.favorites.isFavorite(this.args.pokemon.id);
  }

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
    >
      {{if this.isFavorite "★" "☆"}}
    </button>
  </template>
}
