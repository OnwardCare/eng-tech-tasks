import Service from '@ember/service';

const BASE_URL = 'https://pokeapi.co/api/v2';

export default class PokeDataService extends Service {
  cache = new Map();

  fetchJSON(url) {
    if (!this.cache.has(url)) {
      const promise = fetch(url).then((response) => response.json());
      promise.catch(() => this.cache.delete(url));
      this.cache.set(url, promise);
    }
    return this.cache.get(url);
  }

  fetchList(offset = 0, limit = 20) {
    return this.fetchJSON(
      `${BASE_URL}/pokemon?limit=${limit}&offset=${offset}`,
    );
  }

  async fetchPage(offset = 0, limit = 20) {
    const list = await this.fetchList(offset, limit);
    const details = await Promise.all(
      list.results.map((entry) => this.fetchJSON(entry.url)),
    );
    return details.map((detail) => ({
      id: detail.id,
      name: detail.name,
      sprite: detail.sprites.front_default,
      types: detail.types.map((t) => t.type.name),
    }));
  }

  fetchPokemon(idOrName) {
    return this.fetchJSON(`${BASE_URL}/pokemon/${idOrName}`);
  }

  fetchSpecies(idOrName) {
    return this.fetchJSON(`${BASE_URL}/pokemon-species/${idOrName}`);
  }

  fetchEvolutionChain(url) {
    return this.fetchJSON(url);
  }
}
