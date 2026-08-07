import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

const STORAGE_KEY = 'pokedex-challenge:favorites';

export default class FavoritesService extends Service {
  @tracked items = this.readPersisted();

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
    this.items = [...this.items, this.normalize(pokemon)];
    this.persist();
  }

  normalize(pokemon) {
    return {
      id: pokemon.id,
      name: pokemon.name,
      sprite: pokemon.sprite ?? pokemon.artwork,
      types: pokemon.types,
    };
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

  readPersisted() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (!raw) {
        return [];
      }
      const parsed = JSON.parse(raw);
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [];
    }
  }

  persist() {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(this.items));
    } catch {
      // localStorage unavailable (private browsing, quota, disabled) —
      // fail silently, in-memory state still works for the session.
    }
  }
}
