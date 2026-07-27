import Service from '@ember/service';
import { waitForPromise } from '@ember/test-waiters';

const BASE_URL = 'https://pokeapi.co/api/v2';

export default class PokeDataService extends Service {
  // The list, detail, and featured-rotator UI all independently request the
  // same Pokémon/species/evolution-chain resources. Caching by request key
  // (and caching the in-flight promise, not just the resolved value) means
  // concurrent or repeated requests for the same resource share one fetch
  // instead of hammering the public API.
  #cache = new Map();

  #fetchJSON(cacheKey, url, notFoundMessage) {
    if (this.#cache.has(cacheKey)) {
      return this.#cache.get(cacheKey);
    }

    const promise = fetch(url).then((response) => {
      if (!response.ok) {
        throw new Error(notFoundMessage ?? `Request to ${url} failed.`);
      }
      return response.json();
    });

    this.#cache.set(cacheKey, promise);
    promise.catch(() => this.#cache.delete(cacheKey));

    // Registers the request as a test waiter so `click`/`visit`/`render`
    // test helpers correctly wait for it to settle, since raw fetch()
    // calls aren't tracked by Ember's run loop on their own.
    return waitForPromise(promise);
  }

  fetchList(offset = 0, limit = 20) {
    return this.#fetchJSON(
      `list:${offset}:${limit}`,
      `${BASE_URL}/pokemon?limit=${limit}&offset=${offset}`,
    );
  }

  fetchPokemon(idOrName) {
    return this.#fetchJSON(
      `pokemon:${idOrName}`,
      `${BASE_URL}/pokemon/${idOrName}`,
      `Pokémon "${idOrName}" could not be found.`,
    );
  }

  fetchSpecies(idOrName) {
    return this.#fetchJSON(
      `species:${idOrName}`,
      `${BASE_URL}/pokemon-species/${idOrName}`,
      `Species "${idOrName}" could not be found.`,
    );
  }

  fetchEvolutionChain(url) {
    return this.#fetchJSON(
      `evolution-chain:${url}`,
      url,
      'Evolution chain could not be found.',
    );
  }
}
