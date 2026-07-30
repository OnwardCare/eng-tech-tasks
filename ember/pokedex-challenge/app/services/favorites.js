import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

const STORAGE_KEY = 'my_favorites';

export default class FavoritesService extends Service {
  @tracked items = [];

  constructor() {
    super(...arguments);
    this.loadFromLocalStorage();
  }

  loadFromLocalStorage() {
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored) {
        this.items = JSON.parse(stored);
      }
    } catch (e) {
      console.error('Failed to load favorites from localStorage', e);
      this.items = [];
    }
  }

  updateLocalStorage() {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(this.items));
    } catch (e) {
      console.error('Failed to save favorites to localStorage', e);
    }
  }

  get count() {
    return this.items.length;
  }

  isFavorite(id) {
    return this.items.some((item) => item.id === id);
  }

  add(pokemon) {
    if (!this.isFavorite(pokemon.id)) {
      this.items = [...this.items, pokemon];
      this.updateLocalStorage();
    }
  }

  remove(id) {
    this.items = this.items.filter((item) => item.id !== id);
    this.updateLocalStorage();
  }

  toggle(pokemon) {
    if (this.isFavorite(pokemon.id)) {
      this.remove(pokemon.id);
    } else {
      this.add(pokemon);
    }
  }
}
