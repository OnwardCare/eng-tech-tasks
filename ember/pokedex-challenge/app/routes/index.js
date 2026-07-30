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
    const list = await this.pokeData.fetchList(offset, limit);
    const pokemon = [];
    for (const entry of list.results) {
      const response = await fetch(entry.url);
      const detail = await response.json();
      pokemon.push({
        id: detail.id,
        name: detail.name,
        sprite: detail.sprites.front_default,
        types: detail.types.map((t) => t.type.name),
      });
    }
    return pokemon;
  }
}
