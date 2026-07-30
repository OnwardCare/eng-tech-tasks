import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

export default class FavoritesService extends Service {
  @tracked items = [];

  #localStorageKey = 'pokedex-favorites';
  #localStorageAvailable = true;
  _favoriteIds = new Set();

  constructor(...args) {
    super(...args);
    this.loadFromLocalStorage();
  }

  /**
   * Feature detection: test if localStorage is available
   * @private
   */
  #testLocalStorage() {
    try {
      const test = '__test__';
      localStorage.setItem(test, test);
      localStorage.removeItem(test);
      this.#localStorageAvailable = true;
    } catch (e) {
      this.#localStorageAvailable = false;
    }
  }

  /**
   * Load favorite IDs from localStorage
   * Populates _favoriteIds with stored IDs for lazy-loading
   */
  loadFromLocalStorage() {
    this.#testLocalStorage();
    if (!this.#localStorageAvailable) return;

    try {
      const stored = localStorage.getItem(this.#localStorageKey);
      if (stored) {
        this._favoriteIds = new Set(JSON.parse(stored));
      } else {
        this._favoriteIds = new Set();
      }
    } catch (e) {
      console.warn('Failed to load favorites from localStorage:', e);
      this._favoriteIds = new Set();
    }
  }

  /**
   * Sync current favorite IDs to localStorage
   * Called after any state change (add/remove/toggle)
   * @private
   */
  syncToLocalStorage() {
    if (!this.#localStorageAvailable) return;

    try {
      const ids = this.items.map((item) => item.id);
      localStorage.setItem(this.#localStorageKey, JSON.stringify(ids));
    } catch (e) {
      // localStorage unavailable or quota exceeded; silently ignore
      console.warn('Failed to sync favorites to localStorage:', e);
    }
  }

  get count() {
    return this.items.length;
  }

  isFavorite(id) {
    return this.items.some((item) => item.id === id);
  }

  add(pokemon) {
    this.items.push(pokemon);
    this.syncToLocalStorage();
  }

  remove(id) {
    const index = this.items.findIndex((item) => item.id === id);
    if (index !== -1) {
      this.items.splice(index, 1);
    }
    this.syncToLocalStorage();
  }

  toggle(pokemon) {
    if (this.isFavorite(pokemon.id)) {
      this.remove(pokemon.id);
    } else {
      this.add(pokemon);
    }
  }
}
