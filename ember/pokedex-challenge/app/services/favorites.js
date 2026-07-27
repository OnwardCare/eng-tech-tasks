import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

const STORAGE_KEY = 'pokedex-challenge:favorites';

function readPersisted() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    const parsed = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

function writePersisted(items) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(items));
  } catch {
    // localStorage may be unavailable (private mode, quota, etc). Favorites
    // still work for the session, they just won't survive a reload.
  }
}

// Normalize whatever shape a card/detail page passes in (they carry
// different fields) into the minimal shape favorites needs to render.
function normalize(pokemon) {
  return {
    id: pokemon.id,
    name: pokemon.name,
    sprite: pokemon.sprite ?? pokemon.artwork ?? null,
    types: pokemon.types ?? [],
  };
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
    if (this.isFavorite(pokemon.id)) {
      return;
    }
    this.items = [...this.items, normalize(pokemon)];
    writePersisted(this.items);
  }

  remove(id) {
    this.items = this.items.filter((item) => item.id !== id);
    writePersisted(this.items);
  }

  toggle(pokemon) {
    if (this.isFavorite(pokemon.id)) {
      this.remove(pokemon.id);
    } else {
      this.add(pokemon);
    }
  }
}
