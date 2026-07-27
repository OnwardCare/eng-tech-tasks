import Route from '@ember/routing/route';
import { service } from '@ember/service';

function toCardShape(detail) {
  return {
    id: detail.id,
    name: detail.name,
    sprite: detail.sprites.front_default,
    types: detail.types.map((t) => t.type.name),
  };
}

export default class IndexRoute extends Route {
  @service pokeData;

  async model() {
    const list = await this.pokeData.fetchList(0, 20);
    const details = await Promise.all(
      list.results.map((entry) => this.pokeData.fetchPokemon(entry.name)),
    );
    return details.map(toCardShape);
  }
}
