/* eslint-disable no-console */
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import FeaturedRotator from 'pokedex-challenge/components/featured-rotator';
import PokemonCard from 'pokedex-challenge/components/pokemon-card';

const GEN_1_COUNT = 151;

export default class PokemonList extends Component {
  @service pokeData;

  @tracked searchTerm = '';
  @tracked sortBy = 'id';
  @tracked offset = 0;
  @tracked currentPage = null;

  get pokemon() {
    return this.currentPage || this.args.pokemon;
  }

  get filteredPokemon() {
    let results = this.pokemon;
    if (this.searchTerm) {
      results = results.filter((p) =>
        p.name.toLowerCase().includes(this.searchTerm.toLowerCase()),
      );
    }
    if (this.sortBy === 'name') {
      return results.sort((a, b) => a.name.localeCompare(b.name));
    }
    return results.sort((a, b) => a.id - b.id);
  }

  @action
  updateSearch(event) {
    this.searchTerm = event.target.value;
  }

  @action
  updateSort(event) {
    this.sortBy = event.target.value;
  }

  @action
  async nextPage() {
    if (this.offset + 20 >= GEN_1_COUNT) {
      return;
    }
    this.offset = this.offset + 20;
    const limit = Math.min(20, GEN_1_COUNT - this.offset);
    const list = await this.pokeData.fetchList(this.offset, limit);
    const page = [];
    for (const entry of list.results) {
      const response = await fetch(entry.url);
      const detail = await response.json();
      page.push({
        id: detail.id,
        name: detail.name,
        sprite: detail.sprites.front_default,
        types: detail.types.map((t) => t.type.name),
      });
    }
    this.currentPage = page;
  }

  @action
  previousPage() {
    console.log('previousPage');
  }

  <template>
    <FeaturedRotator />

    <div class="list-controls">
      <input
        type="text"
        placeholder="Search by name"
        value={{this.searchTerm}}
        class="search-input"
        {{on "input" this.updateSearch}}
      />
      <select class="sort-select" {{on "change" this.updateSort}}>
        <option value="id">Sort by ID</option>
        <option value="name">Sort by name</option>
      </select>
    </div>

    <div class="pokemon-grid">
      {{#each this.filteredPokemon as |pokemon|}}
        <PokemonCard @pokemon={{pokemon}} />
      {{/each}}
    </div>

    <div class="pagination">
      <button
        type="button"
        class="page-button"
        {{on "click" this.previousPage}}
      >
        Previous
      </button>
      <button type="button" class="page-button" {{on "click" this.nextPage}}>
        Next
      </button>
    </div>
  </template>
}
