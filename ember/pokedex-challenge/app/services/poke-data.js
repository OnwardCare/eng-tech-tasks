import Service from '@ember/service';

const BASE_URL = 'https://pokeapi.co/api/v2';

export default class PokeDataService extends Service {
  async fetchList(offset = 0, limit = 20) {
    const response = await fetch(
      `${BASE_URL}/pokemon?limit=${limit}&offset=${offset}`,
    );
    return response.json();
  }

  async fetchPage(offset = 0, limit = 20) {
    const list = await this.fetchList(offset, limit);
    const details = await Promise.all(
      list.results.map((entry) => fetch(entry.url).then((r) => r.json())),
    );
    return details.map((detail) => ({
      id: detail.id,
      name: detail.name,
      sprite: detail.sprites.front_default,
      types: detail.types.map((t) => t.type.name),
    }));
  }

  async fetchPokemon(idOrName) {
    const response = await fetch(`${BASE_URL}/pokemon/${idOrName}`);
    return response.json();
  }

  async fetchSpecies(idOrName) {
    const response = await fetch(`${BASE_URL}/pokemon-species/${idOrName}`);
    return response.json();
  }

  async fetchEvolutionChain(url) {
    const response = await fetch(url);
    return response.json();
  }
}
