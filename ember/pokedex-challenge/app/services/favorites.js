import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

export default class FavoritesService extends Service {
  @tracked items = [];

  get count() {
    return this.items.length;
  }

  isFavorite(id) {
    return this.items.some((item) => item.id === id);
  }

  add(pokemon) {
    if (this.isFavorite(pokemon.id)) {
      return;
    }
    this.items = [...this.items, pokemon];
  }

  remove(id) {
    this.items = this.items.filter((item) => item.id !== id);
  }

  toggle(pokemon) {
    if (this.isFavorite(pokemon.id)) {
      this.remove(pokemon.id);
    } else {
      this.add(pokemon);
    }
  }
}
