import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

const FAVORITES_KEY = 'pokedex:favorites';

function loadFromStorage() {
  try {
    const raw = localStorage.getItem(FAVORITES_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

function toFavoriteEntry(pokemon) {
  return {
    id: pokemon.id,
    name: pokemon.name,
    sprite: pokemon.sprite ?? pokemon.artwork,
  };
}

export default class FavoritesService extends Service {
  @tracked items = loadFromStorage();

  persist() {
    localStorage.setItem(FAVORITES_KEY, JSON.stringify(this.items));
  }

  get count() {
    return this.items.length;
  }

  isFavorite(id) {
    return this.items.some((item) => item.id === id);
  }

  add(pokemon) {
    this.items = [...this.items, toFavoriteEntry(pokemon)];
    this.persist();
  }

  remove(id) {
    this.items = this.items.filter((item) => item.id !== id);
    this.persist();
  }

  toggle(pokemon) {
    if (this.isFavorite(pokemon.id)) {
      this.remove(pokemon.id);
    } else {
      this.add(pokemon);
    }
  }
}
