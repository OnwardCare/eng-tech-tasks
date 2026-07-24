import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import AsyncData from 'pokedex-challenge/utils/async-data';
import FeaturedRotator from 'pokedex-challenge/components/featured-rotator';
import PokemonCard from 'pokedex-challenge/components/pokemon-card';

const GEN_1_COUNT = 151;
export const PAGE_SIZE = 20;

export default class PokemonList extends Component {
  @service pokeData;

  @tracked searchTerm = '';
  @tracked sortBy = 'id';
  @tracked offset = 0;

  #pages = new Map();

  get page() {
    return this.#pages.get(this.offset) ?? null;
  }

  get pokemon() {
    return (this.page ? this.page.value : this.args.pokemon) ?? [];
  }

  get filteredPokemon() {
    let results = this.pokemon;
    if (this.searchTerm) {
      const term = this.searchTerm.toLowerCase();
      results = results.filter((p) => p.name.toLowerCase().includes(term));
    }

    return [...results].sort((a, b) =>
      this.sortBy === 'name' ? a.name.localeCompare(b.name) : a.id - b.id,
    );
  }

  get currentPageNumber() {
    return this.offset / PAGE_SIZE + 1;
  }

  get pageCount() {
    return Math.ceil(GEN_1_COUNT / PAGE_SIZE);
  }

  get hasPrevious() {
    return this.offset > 0;
  }

  get hasNext() {
    return this.offset + PAGE_SIZE < GEN_1_COUNT;
  }

  get isFirstPage() {
    return !this.hasPrevious;
  }

  get isLastPage() {
    return !this.hasNext;
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
  previousPage() {
    if (this.hasPrevious) {
      this.goToOffset(this.offset - PAGE_SIZE);
    }
  }

  @action
  nextPage() {
    if (this.hasNext) {
      this.goToOffset(this.offset + PAGE_SIZE);
    }
  }

  goToOffset(offset) {
    if (offset > 0 && !this.#pages.has(offset)) {
      const limit = Math.min(PAGE_SIZE, GEN_1_COUNT - offset);

      this.#pages.set(
        offset,
        new AsyncData(() => this.pokeData.fetchPage(offset, limit)),
      );
    }

    this.offset = offset;
  }

  <template>
    <FeaturedRotator />

    <div class="list-controls">
      <input
        type="text"
        placeholder="Search by name"
        aria-label="Search by name"
        value={{this.searchTerm}}
        class="search-input"
        {{on "input" this.updateSearch}}
      />
      <select
        class="sort-select"
        aria-label="Sort order"
        {{on "change" this.updateSort}}
      >
        <option value="id">Sort by ID</option>
        <option value="name">Sort by name</option>
      </select>
    </div>

    {{#if this.page.isLoading}}
      <p class="list-status">Loading…</p>
    {{else if this.page.error}}
      <p class="list-status list-error">Could not load this page.</p>
    {{else}}
      <div class="pokemon-grid">
        {{#each this.filteredPokemon key="id" as |pokemon|}}
          <PokemonCard @pokemon={{pokemon}} />
        {{/each}}
      </div>
    {{/if}}

    <div class="pagination">
      <button
        type="button"
        class="page-button"
        disabled={{this.isFirstPage}}
        {{on "click" this.previousPage}}
      >
        Previous
      </button>
      <span class="page-indicator">
        Page
        {{this.currentPageNumber}}
        of
        {{this.pageCount}}
      </span>
      <button
        type="button"
        class="page-button"
        disabled={{this.isLastPage}}
        {{on "click" this.nextPage}}
      >
        Next
      </button>
    </div>
  </template>
}
