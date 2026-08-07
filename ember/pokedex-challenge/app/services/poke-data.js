import Service from '@ember/service';

const BASE_URL = 'https://pokeapi.co/api/v2';

function idFromUrl(url) {
  const parts = url.split('/').filter(Boolean);
  return parts[parts.length - 1];
}

function shapeListEntry(detail) {
  return {
    id: detail.id,
    name: detail.name,
    sprite: detail.sprites.front_default,
    types: detail.types.map((t) => t.type.name),
  };
}

function shapeDetail(detail) {
  return {
    id: detail.id,
    name: detail.name,
    height: detail.height,
    weight: detail.weight,
    artwork: detail.sprites.other['official-artwork'].front_default,
    types: detail.types.map((t) => t.type.name),
    abilities: detail.abilities.map((a) => a.ability.name),
    stats: detail.stats.map((s) => ({
      name: s.stat.name,
      value: s.base_stat,
    })),
  };
}

function extractFlavorText(species) {
  const entry = species.flavor_text_entries.find(
    (e) => e.language.name === 'en',
  );
  return entry ? entry.flavor_text : '';
}

function shapeEvolutionStages(chain) {
  const rawStages = [];
  let level = [chain];
  while (level.length > 0) {
    rawStages.push(
      level.map((node) => ({
        id: idFromUrl(node.species.url),
        name: node.species.name,
      })),
    );
    level = level.flatMap((node) => node.evolves_to);
  }
  return rawStages.map((pokemons, index) => ({
    pokemons,
    isLast: index === rawStages.length - 1,
  }));
}

export default class PokeDataService extends Service {
  cache = new Map();

  async fetchJSON(url) {
    if (this.cache.has(url)) {
      return this.cache.get(url);
    }
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`PokéAPI request failed (${response.status}): ${url}`);
    }
    const data = await response.json();
    this.cache.set(url, data);
    return data;
  }

  fetchList(offset = 0, limit = 20) {
    return this.fetchJSON(
      `${BASE_URL}/pokemon?limit=${limit}&offset=${offset}`,
    );
  }

  fetchPokemon(idOrName) {
    return this.fetchJSON(`${BASE_URL}/pokemon/${idOrName}`);
  }

  fetchSpecies(idOrName) {
    return this.fetchJSON(`${BASE_URL}/pokemon-species/${idOrName}`);
  }

  async fetchPage(offset, limit) {
    const list = await this.fetchList(offset, limit);
    const details = await Promise.all(
      list.results.map((entry) => this.fetchJSON(entry.url)),
    );
    return details.map(shapeListEntry);
  }

  async fetchPokemonDetail(idOrName) {
    const [pokemon, species] = await Promise.all([
      this.fetchPokemon(idOrName),
      this.fetchSpecies(idOrName),
    ]);
    const { chain } = await this.fetchJSON(species.evolution_chain.url);
    return {
      ...shapeDetail(pokemon),
      flavorText: extractFlavorText(species),
      evolutionStages: shapeEvolutionStages(chain),
    };
  }
}
