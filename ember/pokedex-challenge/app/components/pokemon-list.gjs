/* eslint-disable no-console */
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import FeaturedRotator from 'pokedex-challenge/components/featured-rotator';
import PokemonCard from 'pokedex-challenge/components/pokemon-card';
import {
  PAGE_SIZE,
  API_POKEMON_LIMIT,
} from 'pokedex-challenge/services/poke-data';

export default class PokemonList extends Component {
  @service pokeData;
  @service listState;

  @tracked searchTerm = '';
  @tracked sortBy = 'id';
  @tracked currentPage = null;
  @tracked isLoading = false;

  get offset() {
    return this.listState.offset;
  }

  get pokemon() {
    return this.currentPage || this.args.pokemon;
  }

  get filteredPokemon() {
    let results = this.pokemon ?? [];
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

  async loadPage(offset) {
    this.isLoading = true;
    try {
      this.listState.offset = offset;
      const limit = Math.min(PAGE_SIZE, API_POKEMON_LIMIT - offset);
      const list = await this.pokeData.fetchList(offset, limit);
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
    } finally {
      this.isLoading = false;
    }
  }

  @action
  async nextPage() {
    if (this.isLoading || this.offset + PAGE_SIZE >= API_POKEMON_LIMIT) {
      return;
    }
    await this.loadPage(this.offset + PAGE_SIZE);
  }

  @action
  async previousPage() {
    if (this.isLoading || this.offset <= 0) {
      return;
    }
    await this.loadPage(this.offset - PAGE_SIZE);
  }

  get isPreviousDisabled() {
    return this.isLoading || this.offset <= 0;
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

    {{#if this.isLoading}}
      <div class="list-loading">Loading Pokémons...</div>
    {{else}}
      <div class="pokemon-grid">
        {{#each this.filteredPokemon as |pokemon|}}
          <PokemonCard @pokemon={{pokemon}} />
        {{/each}}
      </div>
    {{/if}}

    <div class="pagination">
      <button
        type="button"
        class="page-button"
        disabled={{this.isPreviousDisabled}}
        {{on "click" this.previousPage}}
      >
        Previous
      </button>
      <button
        type="button"
        class="page-button"
        disabled={{this.isLoading}}
        {{on "click" this.nextPage}}
      >
        Next
      </button>
    </div>
  </template>
}
