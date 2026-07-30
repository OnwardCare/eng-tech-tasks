import Service from '@ember/service';

const BASE_URL = 'https://pokeapi.co/api/v2';

export default class EvolutionChainService extends Service {
  #cache = new Map(); // Private cache: pokemonId → chain data

  /**
   * Fetch and parse evolution chain for a Pokémon.
   * @param {number} pokemonId - Pokémon ID to fetch evolution for
   * @returns {Promise<{stages: Array<{id: number, name: string}>, hasEvolution: boolean} | null>}
   *   Returns null if no evolution chain found or error occurs
   */
  async fetchEvolutionChain(pokemonId) {
    // Check cache first
    if (this.#cache.has(pokemonId)) {
      return this.#cache.get(pokemonId);
    }

    try {
      // Fetch species data to get evolution chain URL
      const speciesResponse = await fetch(
        `${BASE_URL}/pokemon-species/${pokemonId}`,
      );
      if (!speciesResponse.ok) {
        return null;
      }

      const speciesData = await speciesResponse.json();

      // Check if evolution_chain URL exists
      if (!speciesData.evolution_chain?.url) {
        // No evolution chain; this Pokémon doesn't evolve
        const result = {
          stages: [{ id: pokemonId, name: speciesData.name }],
          hasEvolution: false,
        };
        this.#cache.set(pokemonId, result);
        return result;
      }

      // Fetch the evolution chain
      const chainResponse = await fetch(speciesData.evolution_chain.url);
      if (!chainResponse.ok) {
        return null;
      }

      const chainData = await chainResponse.json();

      // Parse the chain structure
      const stages = this.parseChain(chainData.chain);
      const result = {
        stages,
        hasEvolution: stages.length > 1,
      };

      // Cache the result
      this.#cache.set(pokemonId, result);
      return result;
    } catch {
      // Silently fail; component will handle null result
      return null;
    }
  }

  /**
   * Parse the recursive chain structure from PokéAPI.
   * Extracts species names/IDs in order.
   * @param {Object} chainNode - The chain node object from PokéAPI
   * @returns {Array<{id: number, name: string}>} Ordered list of evolution stages
   */
  parseChain(chainNode) {
    if (!chainNode || typeof chainNode !== 'object') {
      return [];
    }

    const stages = [];

    // Helper function to walk the recursive structure
    const walk = (node) => {
      if (!node || typeof node !== 'object') {
        return;
      }

      // Extract current stage info
      if (node.species?.name) {
        // Extract Pokémon ID from species URL
        // URL format: https://pokeapi.co/api/v2/pokemon-species/{id}/
        const url = node.species.url || '';
        const idMatch = url.match(/\/(\d+)\/$/);
        const id = idMatch ? parseInt(idMatch[1], 10) : null;

        if (id) {
          stages.push({
            id,
            name: node.species.name,
          });
        }
      }

      // Recursively walk all evolution branches
      if (Array.isArray(node.evolves_to) && node.evolves_to.length > 0) {
        node.evolves_to.forEach((evolutionNode) => {
          walk(evolutionNode);
        });
      }
    };

    walk(chainNode);
    return stages;
  }
}
