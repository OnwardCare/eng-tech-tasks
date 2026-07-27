import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

const STORAGE_KEY = 'pokedex-favorites';

export default class FavoritesService extends Service {
  // Load persisted favorites from localStorage on init; default to empty array
  @tracked items = this._load();

  get count() {
    return this.items.length;
  }

  isFavorite(id) {
    return this.items.some((item) => item.id === id);
  }

  add(pokemon) {
    // Reassign instead of mutating so @tracked detects the change
    this.items = [...this.items, pokemon];
    this._persist();
  }

  remove(id) {
    // Reassign to a new filtered array — triggers @tracked update
    this.items = this.items.filter((item) => item.id !== id);
    this._persist();
  }

  toggle(pokemon) {
    if (this.isFavorite(pokemon.id)) {
      this.remove(pokemon.id);
    } else {
      this.add(pokemon);
    }
  }

  // Read from localStorage; returns an empty array if nothing is stored or JSON is invalid
  _load() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch {
      return [];
    }
  }

  // Sync current items to localStorage after every change
  _persist() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(this.items));
  }
}
