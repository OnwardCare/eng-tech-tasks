import Service from '@ember/service';
import { tracked } from '@glimmer/tracking'; 
const LOCAL_STORAGE_KEY = 'favoritePokemon';

export default class FavoritesService extends Service {
  @tracked items = this.restoreFavorites();

  restoreFavorites() {
    try {
      const stored = localStorage.getItem(LOCAL_STORAGE_KEY);
      return stored ? JSON.parse(stored) : [];
    } catch {
      return [];
    }
  }

  saveFavorites() {
    try {
      localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(this.items));
    } catch {
      // Handle error if needed
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
      this.saveFavorites();
    }
  }

  remove(id) {
    const index = this.items.findIndex((item) => item.id === id);
    if (index !== -1) {
      this.items = this.items.filter((item) => item.id !== id);
      this.saveFavorites();
    }
  }

  toggle(pokemon) {
    if (this.isFavorite(pokemon.id)) {
      this.remove(pokemon.id);
    } else {
      this.add(pokemon);
    }
  }
}
