import Service from '@ember/service';

const BASE_URL = 'https://pokeapi.co/api/v2';

export const PAGE_SIZE = 20;
export const API_POKEMON_LIMIT = 1350; // Number based in this API path: https://pokeapi.co/api/v2/pokemon

export default class PokeDataService extends Service {
  async fetchList(offset = 0, limit = PAGE_SIZE) {
    const response = await fetch(
      `${BASE_URL}/pokemon?limit=${limit}&offset=${offset}`,
    );
    if (!response.ok) throw new Error('Failed to fetch list');
    return response.json();
  }

  async fetchPokemon(idOrName) {
    const response = await fetch(`${BASE_URL}/pokemon/${idOrName}`);
    if (!response.ok) throw new Error(`Failed to fetch pokemon "${idOrName}"`);
    return response.json();
  }

  async fetchSpecies(idOrName) {
    const response = await fetch(`${BASE_URL}/pokemon-species/${idOrName}`);
    if (!response.ok) throw new Error(`Failed to fetch species "${idOrName}"`);
    return response.json();
  }

  async fetchEvolutionChain(pokemonId) {
    const speciesRes = await fetch(`${BASE_URL}/pokemon-species/${pokemonId}`);
    if (!speciesRes.ok) throw new Error('Failed to fetch evolution chain');
    const speciesData = await speciesRes.json();
    const response = await fetch(speciesData.evolution_chain.url);
    if (!response.ok) throw new Error('Failed to fetch evolution chain');
    return response.json();
  }

  async fetchPokemonPage(offset = 0, limit = PAGE_SIZE) {
    const list = await this.fetchList(offset, limit);
    return Promise.all(
      list.results.map(async (entry) => {
        const detail = await this.fetchPokemon(entry.name);
        return {
          id: detail.id,
          name: detail.name,
          sprite: detail.sprites.front_default,
          types: detail.types.map((t) => t.type.name),
        };
      }),
    );
  }
  s;
}
