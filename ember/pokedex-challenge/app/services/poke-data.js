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

  async fetchEvolutionChain(pokemonId) {
    const response = await fetch(`${BASE_URL}/evolution-chain/${pokemonId}/`);
    const chainData = await response.json();

    return this.getEvolutionString(chainData.chain);
  }

  getEvolutionString(chain) {
    const name = chain.species?.name;
    
    if (!name) {
      return '';
    }

    if (!chain.evolves_to || chain.evolves_to.length === 0) {
      return name;
    }
  
    return `${name} -> ${this.getEvolutionString(chain.evolves_to[0])}`;
  }
}
