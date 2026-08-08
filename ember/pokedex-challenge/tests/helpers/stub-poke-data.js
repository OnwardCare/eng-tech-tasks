import Service from '@ember/service';
import { GEN_1_COUNT } from 'pokedex-challenge/services/poke-data';

// Real names for the ids the tests assert on; anything else gets a filler.
const NAMES = {
  1: 'bulbasaur',
  2: 'ivysaur',
  3: 'venusaur',
  21: 'spearow',
  25: 'pikachu',
};

export function stubPokemon(id) {
  return {
    id,
    name: NAMES[id] ?? `pokemon-${id}`,
    sprite: `/sprites/${id}.png`,
    artwork: `/artwork/${id}.png`,
    height: 7,
    weight: 69,
    types: ['normal'],
    abilities: ['stub-ability'],
    stats: [{ name: 'hp', value: 45 }],
  };
}

export default class StubPokeDataService extends Service {
  async fetchPokemon(idOrName) {
    return stubPokemon(Number(idOrName));
  }

  async fetchPage(offset = 0, limit = 20) {
    const remaining = Math.max(0, GEN_1_COUNT - offset);

    return Array.from({ length: Math.min(limit, remaining) }, (_, index) =>
      stubPokemon(offset + index + 1),
    );
  }

  async fetchSpecies() {
    return { flavorText: 'A stubbed flavor text.', evolutionChainUrl: null };
  }

  async fetchEvolutionChain() {
    return [];
  }
}
