import Route from '@ember/routing/route';
import { service } from '@ember/service';

const GEN_1_COUNT = 151;
const PAGE_SIZE = 20;

export default class IndexRoute extends Route {
  @service pokeData;

  queryParams = {
    page: { refreshModel: true },
  };

  async model(params) {
    const page = Number(params.page) || 1;
    const offset = (page - 1) * PAGE_SIZE;
    const pokemon = await this.pokeData.fetchPage(offset, PAGE_SIZE);
    return {
      pokemon,
      page,
      hasPrevious: page > 1,
      hasNext: offset + PAGE_SIZE < GEN_1_COUNT,
    };
  }
}
