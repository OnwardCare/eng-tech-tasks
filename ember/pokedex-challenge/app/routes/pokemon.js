import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class PokemonRoute extends Route {
  @service pokeData;

  model(params) {
    return this.pokeData.fetchPokemonDetail(params.pokemon_id);
  }
}
