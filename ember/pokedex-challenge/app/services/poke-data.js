import Service from '@ember/service';

const BASE_URL = 'https://pokeapi.co/api/v2';

export default class PokeDataService extends Service {
  async fetchList(offset = 0, limit = 20) {
    const response = await fetch(
      `${BASE_URL}/pokemon?limit=${limit}&offset=${offset}`,
    );
    return response.json();
  }

  async fetchPokemon(idOrName) {
    const response = await fetch(`${BASE_URL}/pokemon/${idOrName}`);
    if (!response.ok) {
      throw new Error(`Pokémon "${idOrName}" could not be found.`);
    }
    return response.json();
  }

  async fetchSpecies(idOrName) {
    const response = await fetch(`${BASE_URL}/pokemon-species/${idOrName}`);
    if (!response.ok) {
      throw new Error(`Species "${idOrName}" could not be found.`);
    }
    return response.json();
  }

  async fetchEvolutionChain(url) {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error('Evolution chain could not be found.');
    }
    return response.json();
  }
}
