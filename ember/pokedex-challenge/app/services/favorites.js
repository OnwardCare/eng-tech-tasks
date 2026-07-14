import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';
import config from 'pokedex-challenge/config/environment';

const STORAGE_KEY = 'pokedex-favorites';

export default class FavoritesService extends Service {
  @tracked items = [];

  constructor() {
    super(...arguments);
    if (config.environment === 'test') return;
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored) this.items = JSON.parse(stored);
    } catch {
      this.items = [];
    }
  }

  get count() {
    return this.items.length;
  }

  isFavorite(id) {
    return this.items.some((item) => item.id === id);
  }

  add(pokemon) {
    const entry = {
      id: pokemon.id,
      name: pokemon.name,
      sprite: pokemon.sprite ?? pokemon.artwork,
      types: pokemon.types ?? [],
    };
    this.items = [...this.items, entry];
    this.#persist();
  }

  remove(id) {
    this.items = this.items.filter((item) => item.id !== id);
    this.#persist();
  }

  toggle(pokemon) {
    this.isFavorite(pokemon.id) ? this.remove(pokemon.id) : this.add(pokemon);
  }

  #persist() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(this.items));
  }
}
