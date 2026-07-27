import Service from '@ember/service';

const BASE_URL = "https://pokeapi.co/api/v2";

export default class PokeDataService extends Service {
  _cache = new Map();

  async fetchList(offset = 0, limit = 20) {
    const response = await fetch(
      `${BASE_URL}/pokemon?limit=${limit}&offset=${offset}`,
    );
    return response.json();
  }

  // Uses Map to cache Pokémon data by ID or name to prevent redundant API calls
  async fetchPokemon(idOrName) {
    const key = `pokemon_${idOrName}`;
    if (this._cache.has(key)) {
      return this._cache.get(key);
    }
    const response = await fetch(`${BASE_URL}/pokemon/${idOrName}`);
    const data = await response.json();
    this._cache.set(key, data);
    return data;
  }

  // Uses Map to cache Species data by ID or name
  async fetchSpecies(idOrName) {
    const key = `species_${idOrName}`;
    if (this._cache.has(key)) {
      return this._cache.get(key);
    }
    const response = await fetch(`${BASE_URL}/pokemon-species/${idOrName}`);
    const data = await response.json();
    this._cache.set(key, data);
    return data;
  }
}
