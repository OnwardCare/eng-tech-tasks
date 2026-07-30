import Route from '@ember/routing/route';
import { service } from '@ember/service';
import {
  PAGE_SIZE,
  API_POKEMON_LIMIT,
} from 'pokedex-challenge/services/poke-data';

export default class IndexRoute extends Route {
  @service pokeData;
  @service listState;

  async model() {
    const offset = this.listState.offset;
    const limit = Math.min(PAGE_SIZE, API_POKEMON_LIMIT - offset);
    return this.pokeData.fetchPokemonPage(offset, limit);
  }
}
