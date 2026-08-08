import Route from '@ember/routing/route';
import { service } from '@ember/service';
import { GEN_1_COUNT } from 'pokedex-challenge/services/poke-data';

export const PAGE_SIZE = 20;

const PAGE_COUNT = Math.ceil(GEN_1_COUNT / PAGE_SIZE);

function clampPage(value) {
  const page = Number.parseInt(value, 10);

  if (Number.isNaN(page)) {
    return 1;
  }

  return Math.min(Math.max(page, 1), PAGE_COUNT);
}

export default class IndexRoute extends Route {
  @service pokeData;

  queryParams = {
    page: { refreshModel: true },
  };

  async model(params) {
    const page = clampPage(params.page);

    return {
      page,
      pageCount: PAGE_COUNT,
      pokemon: await this.pokeData.fetchPage((page - 1) * PAGE_SIZE, PAGE_SIZE),
    };
  }
}
