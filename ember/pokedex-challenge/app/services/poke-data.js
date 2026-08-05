import Service from '@ember/service';

const BASE_URL = 'https://pokeapi.co/api/v2';

function cached(cache, key, load) {
  const cacheKey = String(key);
  if (!cache.has(cacheKey)) {
    cache.set(
      cacheKey,
      load().catch((error) => {
        cache.delete(cacheKey);
        throw error;
      }),
    );
  }
  return cache.get(cacheKey);
}

export default class PokeDataService extends Service {
  #listCache = new Map();
  #pokemonCache = new Map();
  #speciesCache = new Map();
  #evolutionChainCache = new Map();

  fetchList(offset = 0, limit = 20) {
    return cached(this.#listCache, `${offset}:${limit}`, () =>
      fetch(`${BASE_URL}/pokemon?limit=${limit}&offset=${offset}`).then(
        (response) => response.json(),
      ),
    );
  }

  fetchPokemon(id) {
    return cached(this.#pokemonCache, id, () =>
      fetch(`${BASE_URL}/pokemon/${id}`).then((response) => response.json()),
    );
  }

  fetchSpecies(id) {
    return cached(this.#speciesCache, id, () =>
      fetch(`${BASE_URL}/pokemon-species/${id}`).then((response) =>
        response.json(),
      ),
    );
  }

  fetchEvolutionChain(url) {
    return cached(this.#evolutionChainCache, url, () =>
      fetch(url).then((response) => response.json()),
    );
  }
}
