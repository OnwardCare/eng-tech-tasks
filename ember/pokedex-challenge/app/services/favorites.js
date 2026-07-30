import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

const STORAGE_KEY = 'pokedex:favorites';

function readPersisted() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

export default class FavoritesService extends Service {
  @tracked items = readPersisted();

  get count() {
    return this.items.length;
  }

  isFavorite(id) {
    return this.items.some((item) => item.id === id);
  }

  add(pokemon) {
    this.items = [...this.items, pokemon];
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

  persist() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(this.items));
  }
}
