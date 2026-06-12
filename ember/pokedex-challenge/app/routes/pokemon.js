import Route from '@ember/routing/route';

export default class PokemonRoute extends Route {
  model(params) {
    return params.pokemon_id;
  }
}
