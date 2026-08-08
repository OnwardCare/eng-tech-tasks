import Service from '@ember/service';

const BASE_URL = 'https://pokeapi.co/api/v2';

export const GEN_1_COUNT = 151;

function normalizePokemon(data) {
  return {
    id: data.id,
    name: data.name,
    sprite: data.sprites.front_default,
    artwork:
      data.sprites.other?.['official-artwork']?.front_default ??
      data.sprites.front_default,
    height: data.height,
    weight: data.weight,
    types: data.types.map((t) => t.type.name),
    abilities: data.abilities.map((a) => a.ability.name),
    stats: data.stats.map((s) => ({ name: s.stat.name, value: s.base_stat })),
  };
}

export default class PokeDataService extends Service {
  #requests = new Map();

  // Deduplicates concurrent callers and caches responses for the session.
  request(url) {
    let pending = this.#requests.get(url);

    if (!pending) {
      pending = this.#fetchJSON(url).catch((error) => {
        this.#requests.delete(url);
        throw error;
      });
      this.#requests.set(url, pending);
    }

    return pending;
  }

  async #fetchJSON(url) {
    const response = await fetch(url);

    if (!response.ok) {
      throw new Error(`Request to ${url} failed with ${response.status}`);
    }

    return response.json();
  }

  async fetchPokemon(idOrName) {
    return normalizePokemon(
      await this.request(`${BASE_URL}/pokemon/${idOrName}`),
    );
  }

  async fetchPage(offset = 0, limit = 20) {
    const remaining = Math.max(0, GEN_1_COUNT - offset);

    if (remaining === 0) {
      return [];
    }

    const list = await this.request(
      `${BASE_URL}/pokemon?limit=${Math.min(limit, remaining)}&offset=${offset}`,
    );

    return Promise.all(
      list.results.map(async (entry) =>
        normalizePokemon(await this.request(entry.url)),
      ),
    );
  }
}
