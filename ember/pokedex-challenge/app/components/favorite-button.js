import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';

export default class FavoriteButtonComponent extends Component {
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
}
