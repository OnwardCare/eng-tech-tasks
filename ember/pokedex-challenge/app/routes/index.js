import Route from '@ember/routing/route';
import { service } from '@ember/service';

const GEN_1_COUNT = 151;
const PAGE_SIZE = 20;

export default class IndexRoute extends Route {
  @service pokeData;

  queryParams = {
    page: { refreshModel: true },
  };

  async model({ page = 1 } = {}) {
    const offset = (Number(page) - 1) * PAGE_SIZE;
    const limit = Math.min(PAGE_SIZE, GEN_1_COUNT - offset);
    const [list, allNames] = await Promise.all([
      this.pokeData.fetchList(offset, limit),
      this.pokeData.fetchNames(),
    ]);
    const pokemon = await Promise.all(
      list.results.map(async (entry) => {
        const id = Number(entry.url.split('/').filter(Boolean).pop());
        const detail = await this.pokeData.fetchPokemon(id);
        return {
          id: detail.id,
          name: detail.name,
          sprite: detail.sprites.front_default,
          types: detail.types.map((t) => t.type.name),
        };
      }),
    );
    return { pokemon, allNames, page: Number(page) };
  }
}
