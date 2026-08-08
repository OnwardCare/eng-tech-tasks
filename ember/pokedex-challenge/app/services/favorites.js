import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

const STORAGE_KEY = 'pokedex:favorites';

// Favorites are rendered as cards, so store exactly what a card needs rather
// than whichever richer object the caller happened to have.
function toEntry({ id, name, sprite, types }) {
  return { id, name, sprite, types };
}

function load() {
  try {
    const stored = JSON.parse(localStorage.getItem(STORAGE_KEY));
    return Array.isArray(stored)
      ? stored.filter((entry) => entry && typeof entry.id === 'number')
      : [];
  } catch {
    return [];
  }
}

export default class FavoritesService extends Service {
  @tracked items = load();

  get count() {
    return this.items.length;
  }

  isFavorite(id) {
    return this.items.some((item) => item.id === id);
  }

  add(pokemon) {
    if (!this.isFavorite(pokemon.id)) {
      this.#persist([...this.items, toEntry(pokemon)]);
    }
  }

  remove(id) {
    this.#persist(this.items.filter((item) => item.id !== id));
  }

  toggle(pokemon) {
    if (this.isFavorite(pokemon.id)) {
      this.remove(pokemon.id);
    } else {
      this.add(pokemon);
    }
  }

  #persist(items) {
    this.items = items;

    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(items));
    } catch {
      // Storage can be unavailable or full; in-memory state still works.
    }
  }
}
