import Service from '@ember/service';
import { cached, tracked } from '@glimmer/tracking';

export const STORAGE_KEY = 'pokedex-challenge:favorites';

function toEntry(pokemon) {
  return {
    id: Number(pokemon.id),
    name: pokemon.name,
    sprite: pokemon.sprite ?? pokemon.artwork ?? null,
    types: pokemon.types ?? [],
  };
}

export default class FavoritesService extends Service {
  @tracked items = [];

  constructor() {
    super(...arguments);
    this.items = this.#read();
    window.addEventListener('storage', this.#handleStorage);
  }

  willDestroy() {
    window.removeEventListener('storage', this.#handleStorage);
    super.willDestroy(...arguments);
  }

  get count() {
    return this.items.length;
  }

  @cached
  get favoriteIds() {
    return new Set(this.items.map((item) => item.id));
  }

  isFavorite(id) {
    return this.favoriteIds.has(Number(id));
  }

  add(pokemon) {
    if (!pokemon || this.isFavorite(pokemon.id)) {
      return;
    }

    this.#commit([...this.items, toEntry(pokemon)]);
  }

  remove(id) {
    const idToRemove = Number(id);

    this.#commit(this.items.filter((item) => item.id !== idToRemove));
  }

  toggle(pokemon) {
    if (this.isFavorite(pokemon.id)) {
      this.remove(pokemon.id);
    } else {
      this.add(pokemon);
    }
  }

  #commit(items) {
    this.items = items;
    this.#write(items);
  }

  #handleStorage = (event) => {
    if (event.key === null || event.key === STORAGE_KEY) {
      this.items = this.#read();
    }
  };

  #read() {
    try {
      const stored = JSON.parse(localStorage.getItem(STORAGE_KEY) ?? '[]');

      if (!Array.isArray(stored)) {
        return [];
      }

      return stored
        .filter((entry) => Number.isFinite(Number(entry?.id)))
        .map(toEntry);
    } catch {
      return [];
    }
  }

  #write(items) {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(items));
    } catch {
      // Out of quota or storage unavailable — the in-memory state is still
      // correct, it just won't survive a reload.
    }
  }
}
