import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';

export default class PokemonDetailComponent extends Component {
  @tracked pokemon = null;
  @tracked flavorText = '';

  constructor() {
    super(...arguments);
    this.loadPokemon();
  }

  async loadPokemon() {
    const response = await fetch(
      `https://pokeapi.co/api/v2/pokemon/${this.args.pokemonId}`,
    );
    const data = await response.json();
    console.log('loaded pokemon', data.name);
    this.pokemon = {
      id: data.id,
      name: data.name,
      height: data.height,
      weight: data.weight,
      artwork: data.sprites.other['official-artwork'].front_default,
      types: data.types.map((t) => t.type.name),
      abilities: data.abilities.map((a) => a.ability.name),
      stats: data.stats.map((s) => ({
        name: s.stat.name,
        value: s.base_stat,
      })),
    };
    const speciesResponse = await fetch(
      `https://pokeapi.co/api/v2/pokemon-species/${data.id}`,
    );
    const species = await speciesResponse.json();
    const entry = species.flavor_text_entries.find(
      (e) => e.language.name === 'en',
    );
    this.flavorText = entry ? entry.flavor_text : '';
  }
}
