import Service from '@ember/service';
import { service } from '@ember/service';

export default class FavoritesService extends Service {
  @service store;
  @service localStorage;
  
  async load() {
    try {
      this.populateStoreFromStorage();

      await Promise.resolve();
    } catch (error) {
      console.error(error);
      this.populateStoreFromStorage();
    }
  }

  get count() {
    return this.store.peekAll('pokemon').length;
  }

  get items() {
    return this.store.peekAll('pokemon');
  }

  isFavorite(id) {
    const items = []
    const itemsFromStore = this.store.peekAll('pokemon');

    if (itemsFromStore && itemsFromStore.length === 0) {
      return false;
    }


      for (const item of itemsFromStore) {
        items.push(item);
      }


    return items.some((item) => item.id === String(id));
  }

  add(pokemon) {
    this.addToStore(pokemon);
    this.localStorage.add(pokemon);
  }

  remove(id) {
    this.removeFromStore(id);
    this.localStorage.remove(id);
  }

  toggle(pokemon) {
    if (this.isFavorite(pokemon.id)) {
      this.remove(pokemon.id);
    } else {
      this.add(pokemon);
    }
  }

  // TODO: Move this to separate concerns. In case store api change. Maybe to store service.
  addToStore(pokemon) {
    if (pokemon) {
      this.store.push({
        data: {
          type: 'pokemon',
          id: String(pokemon.id),
          attributes: {
            name: pokemon.name,
            sprite: pokemon.sprite,
            types: pokemon.types,
          },
        }
      });
    }
  }

  // TODO: Move this to separate concerns. In case store api change. Maybe to store service.
  removeFromStore(id) {
    const pokemon = this.store.peekRecord('pokemon', String(id));

    if (pokemon) {
      this.store.unloadRecord(pokemon)
    }
  }

  // TODO: Move this to separate concerns. In case store api change. Maybe to store service.
  populateStoreFromStorage() {
    if (this.localStorage.items && this.localStorage.items.length > 0) {
      const storageItems = this.localStorage.items;
      
      for (const item of storageItems) {
        this.addToStore(item);
      }
    }
  }
}
