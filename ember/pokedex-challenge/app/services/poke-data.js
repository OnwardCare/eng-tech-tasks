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
    if (!speciesRes.ok) {
      return {
        unavailable: true,
        message: 'No available for this Pokemon.',
      };
    }
    const speciesData = await speciesRes.json();

    const response = await fetch(speciesData.evolution_chain.url);
    if (!response.ok) throw new Error('Failed to fetch evolution chain');
    return response.json();
  }

  // Helper function to convert the raw Pokemon data into a format that can be used by the PokemonCard component
  PokemonDataCard(detail) {
    return {
      id: detail.id,
      name: detail.name,
      sprite:
        detail.sprites.front_default ||
        detail.sprites.other['official-artwork'].front_default,
      types: detail.types.map((t) => t.type.name),
    };
  }

  async fetchPokemonPage(offset = 0, limit = PAGE_SIZE) {
    const list = await this.fetchList(offset, limit);
    return Promise.all(
      list.results.map(async (entry) => {
        const detail = await this.fetchPokemon(entry.name);
        return this.PokemonDataCard(detail);
      }),
    );
  }

  async fetchEmAllPokemons() {
    const list = await this.fetchList(0, API_POKEMON_LIMIT);
    return list.results.map((entry) => {
      const segments = entry.url.split('/').filter(Boolean);
      return {
        name: entry.name,
      };
    });
  }

  async searchPokemons(query, limit = PAGE_SIZE) {
    const term = query.trim().toLowerCase();
    if (!term) {
      return [];
    }

    // Gotta catch 'em all since there is no partial search in the API
    const pokemons = await this.fetchEmAllPokemons();
    const matches = pokemons
      .filter((p) => p.name.includes(term))
      .slice(0, limit);

    return Promise.all(
      matches.map(async (p) => {
        const data = await this.fetchPokemon(p.name);
        return this.PokemonDataCard(data);
      }),
    );
  }
}
