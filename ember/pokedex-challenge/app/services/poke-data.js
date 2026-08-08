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

function normalizeSpecies(data) {
  const entry = data.flavor_text_entries.find((e) => e.language.name === 'en');

  return {
    // Flavor text ships with hard line breaks and form feeds baked in.
    flavorText: entry ? entry.flavor_text.replace(/\s+/g, ' ').trim() : '',
    evolutionChainUrl: data.evolution_chain?.url ?? null,
  };
}

function speciesId(url) {
  const [, id] = url.match(/\/pokemon-species\/(\d+)\/?$/) ?? [];
  return Number(id);
}

// Flattens the recursive chain into one entry per evolution stage, so a
// branching line (Eevee, Poliwag) keeps every branch at the right depth.
function toStages(chain) {
  const stages = [];
  let level = [chain];

  while (level.length > 0) {
    stages.push(
      level.map((node) => ({
        id: speciesId(node.species.url),
        name: node.species.name,
      })),
    );
    level = level.flatMap((node) => node.evolves_to);
  }

  return stages;
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

  async fetchSpecies(idOrName) {
    return normalizeSpecies(
      await this.request(`${BASE_URL}/pokemon-species/${idOrName}`),
    );
  }

  async fetchEvolutionChain(url) {
    const { chain } = await this.request(url);
    const stages = toStages(chain);

    if (stages.length < 2) {
      return [];
    }

    return Promise.all(
      stages.map((stage) =>
        Promise.all(stage.map((entry) => this.#withSprite(entry))),
      ),
    );
  }

  // A chain can reach species outside gen 1; a missing sprite must not take
  // the whole detail page down with it.
  async #withSprite(entry) {
    try {
      const { sprite } = await this.fetchPokemon(entry.id);
      return { ...entry, sprite };
    } catch {
      return { ...entry, sprite: null };
    }
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
