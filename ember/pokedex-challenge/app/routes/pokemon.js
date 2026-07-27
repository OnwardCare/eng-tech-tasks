import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class PokemonRoute extends Route {
  @service pokeData;

  // Fetch all data in the route so the component is purely presentational.
  // This also ensures navigation via the evolution chain re-runs the model hook
  // and renders fresh data for the new Pokémon.
  async model(params) {
    const [data, species] = await Promise.all([
      this.pokeData.fetchPokemon(params.pokemon_id),
      this.pokeData.fetchSpecies(params.pokemon_id),
    ]);

    const entry = species.flavor_text_entries.find(
      (e) => e.language.name === 'en',
    );

    return {
      id: data.id,
      name: data.name,
      height: data.height,
      weight: data.weight,
      artwork: data.sprites.other['official-artwork'].front_default,
      types: data.types.map((t) => t.type.name),
      abilities: data.abilities.map((a) => a.ability.name),
      stats: data.stats.map((s) => ({
        name: s.stat.name,
        value: s.base_stat,
      })),
      flavorText: entry ? entry.flavor_text : '',
      evolutionChainUrl: species.evolution_chain.url,
    };
  }
}
