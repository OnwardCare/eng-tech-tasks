import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';

export const STORAGE_KEY = 'pokemons';

export default class LocalStorageService extends Service {
  @service store
  @tracked items = this.load();

  load() {
    const value = localStorage.getItem(STORAGE_KEY);

    if (!value) {
      return [];
    }

    try {
      return JSON.parse(value);
    } catch {
      return [];
    }
  }

  save(items) {
    this.items = items;

    localStorage.setItem(
    STORAGE_KEY,
    JSON.stringify(items)
    );
  }

  add(pokemon) {
    this.save([
      ...this.items,
      pokemon,
    ]);
  }

  remove(id) {
    this.save(
      this.items.filter((pokemon) => {
        return String(pokemon.id) !== id}
    )
    );
  }
}
