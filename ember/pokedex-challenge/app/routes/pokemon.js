import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class PokemonRoute extends Route {
  @service pokeData;

  async model(params) {
    const pokemon = await this.pokeData.fetchPokemon(params.pokemon_id);
    const species = await this.pokeData.fetchSpecies(pokemon.id);

    return {
      pokemon,
      flavorText: species.flavorText,
      evolutions: species.evolutionChainUrl
        ? await this.pokeData.fetchEvolutionChain(species.evolutionChainUrl)
        : [],
    };
  }
}
