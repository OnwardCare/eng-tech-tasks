import Service from '@ember/service';

const BASE_URL = 'https://pokeapi.co/api/v2';

export const PAGE_SIZE = 20;
export const API_POKEMON_LIMIT = 1350; // Number based in this API path: https://pokeapi.co/api/v2/pokemon

export default class PokeDataService extends Service {
  async fetchList(offset = 0, limit = PAGE_SIZE) {
    const response = await fetch(
      `${BASE_URL}/pokemon?limit=${limit}&offset=${offset}`,
    );
    return response.json();
  }

  async fetchPokemon(idOrName) {
    const response = await fetch(`${BASE_URL}/pokemon/${idOrName}`);
    return response.json();
  }

  async fetchEvolutionChain(pokemonId) {
    const speciesRes = await fetch(`${BASE_URL}/pokemon-species/${pokemonId}`);
    if (!speciesRes.ok) throw new Error('Species not found');
    const speciesData = await speciesRes.json();

    const response = await fetch(speciesData.evolution_chain.url);
    if (!response.ok) throw new Error('Evolution chain not found');
    return response.json();
  }
}
