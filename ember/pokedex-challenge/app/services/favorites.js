import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

const STORAGE_KEY = 'pokedex-challenge:favorites';

export default class FavoritesService extends Service {
  @tracked items = [];

  constructor() {
    super(...arguments);
    this.items = this.loadFromStorage();
  }

  get count() {
    return this.items.length;
  }

  isFavorite(id) {
    return this.items.some((item) => item.id === id);
  }

  add(pokemon) {
    const normalized = this.normalize(pokemon);
    this.items = [...this.items, normalized];
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

  // NOTE: The /favorites page didn't always load the images
  // this will ensure the image is correctly loaded into localStorage
  normalize(pokemon) {
    return {
      id: pokemon.id,
      name: pokemon.name,
      sprite: pokemon.sprite ?? pokemon.artwork ?? null,
      types: pokemon.types ?? [],
    };
  }

  loadFromStorage() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch (e) {
      console.error('Failed to load favorites from localStorage', e);
      return [];
    }
  }

  persist() {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(this.items));
    } catch (e) {
      console.error('Failed to persist favorites to localStorage', e);
    }
  }
}
