import Service from '@ember/service';

const BASE_URL = "https://pokeapi.co/api/v2";

export default class PokeDataService extends Service {
  async fetchList(offset = 0, limit = 20) {
    const response = await fetch(
      `${BASE_URL}/pokemon?limit=${limit}&offset=${offset}`,
    );
    return response.json();
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
