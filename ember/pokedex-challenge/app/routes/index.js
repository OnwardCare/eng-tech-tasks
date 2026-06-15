import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class IndexRoute extends Route {
  @service pokeData;

  async model() {
    const list = await this.pokeData.fetchList(0, 20);
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
