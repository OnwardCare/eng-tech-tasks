import Service from '@ember/service';

const BASE_URL = 'https://pokeapi.co/api/v2';

export default class PokeDataService extends Service {
  #cache = new Map();

  fetchList(offset = 0, limit = 20) {
    const key = `list:${offset}:${limit}`;
    if (!this.#cache.has(key)) {
      this.#cache.set(
        key,
        fetch(`${BASE_URL}/pokemon?limit=${limit}&offset=${offset}`).then((r) =>
          r.json(),
        ),
      );
    }
    return this.#cache.get(key);
  }

  fetchNames() {
    const key = 'names:all';
    if (!this.#cache.has(key)) {
      this.#cache.set(
        key,
        fetch(`${BASE_URL}/pokemon?limit=151&offset=0`)
          .then((r) => r.json())
          .then((data) =>
            data.results.map((entry) => ({
              id: Number(entry.url.split('/').filter(Boolean).pop()),
              name: entry.name,
            })),
          ),
      );
    }
    return this.#cache.get(key);
  }

  fetchPokemon(idOrName) {
    const key = `pokemon:${idOrName}`;
    if (!this.#cache.has(key)) {
      this.#cache.set(
        key,
        fetch(`${BASE_URL}/pokemon/${idOrName}`).then((r) => r.json()),
      );
    }
    return this.#cache.get(key);
  }
}
