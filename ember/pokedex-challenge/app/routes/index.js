import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class IndexRoute extends Route {
  @service pokeData;

  async model() {
    const list = await this.pokeData.fetchList(0, 20);

    // Fetch all 20 Pokémon in parallel instead of sequentially — cuts load time proportionally
    const pokemon = await Promise.all(
      list.results.map(async (entry) => {
        const detail = await this.pokeData.fetchPokemon(
          entry.url.split('/').at(-2),
        );
        return {
          id: detail.id,
          name: detail.name,
          sprite: detail.sprites.front_default,
          types: detail.types.map((t) => t.type.name),
        };
      }),
    );

    return pokemon;
  }
}
