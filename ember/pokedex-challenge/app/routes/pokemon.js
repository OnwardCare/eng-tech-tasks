import Route from '@ember/routing/route';
import { service } from '@ember/service';

const BASE_URL = 'https://pokeapi.co/api/v2';

function extractId(url) {
  return Number(url.split('/').filter(Boolean).pop());
}

function walkChain(node) {
  const current = { id: extractId(node.species.url), name: node.species.name };
  if (node.evolves_to.length === 0) return [current];
  if (node.evolves_to.length === 1)
    return [current, ...walkChain(node.evolves_to[0])];
  const branches = node.evolves_to.map((evo) => ({
    id: extractId(evo.species.url),
    name: evo.species.name,
    isBranch: true,
  }));
  return [current, ...branches];
}

function addSeparators(stages) {
  return stages.map((stage, i) => {
    if (i === 0) return { ...stage, separator: null };
    const separator = stage.isBranch && stages[i - 1].isBranch ? '|' : '→';
    return { ...stage, separator };
  });
}

export default class PokemonRoute extends Route {
  @service pokeData;

  async model({ pokemon_id }) {
    const [pokemon, species] = await Promise.all([
      this.pokeData.fetchPokemon(pokemon_id),
      fetch(`${BASE_URL}/pokemon-species/${pokemon_id}`).then((r) => r.json()),
    ]);

    const chainData = await fetch(species.evolution_chain.url).then((r) =>
      r.json(),
    );
    const evolutionChain = addSeparators(walkChain(chainData.chain));

    const entry = species.flavor_text_entries.find(
      (e) => e.language.name === 'en',
    );

    return {
      id: pokemon.id,
      name: pokemon.name,
      height: pokemon.height,
      weight: pokemon.weight,
      artwork: pokemon.sprites.other['official-artwork'].front_default,
      types: pokemon.types.map((t) => t.type.name),
      abilities: pokemon.abilities.map((a) => a.ability.name),
      stats: pokemon.stats.map((s) => ({
        name: s.stat.name,
        value: s.base_stat,
      })),
      flavorText: entry ? entry.flavor_text : '',
      evolutionChain,
    };
  }
}
