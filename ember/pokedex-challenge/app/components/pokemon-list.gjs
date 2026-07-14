import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import FeaturedRotator from 'pokedex-challenge/components/featured-rotator';
import PokemonCard from 'pokedex-challenge/components/pokemon-card';

const GEN_1_COUNT = 151;
const PAGE_SIZE = 20;

export default class PokemonList extends Component {
  @service router;

  @tracked searchTerm = '';
  @tracked sortBy = 'id';
  #searchTimeout = null;

  get currentPage() {
    return Number(this.args.page ?? 1);
  }

  get totalPages() {
    return Math.ceil(GEN_1_COUNT / PAGE_SIZE);
  }

  get isFirstPage() {
    return this.currentPage <= 1;
  }

  get isLastPage() {
    return this.currentPage >= this.totalPages;
  }

  get searchResults() {
    if (!this.searchTerm) return null;
    return this.args.allNames
      .filter((p) =>
        p.name.toLowerCase().includes(this.searchTerm.toLowerCase()),
      )
      .map((p) => ({
        ...p,
        sprite: `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${p.id}.png`,
        types: [],
      }));
  }

  get filteredPokemon() {
    let results = this.args.pokemon;
    if (this.sortBy === 'name') {
      return [...results].sort((a, b) => a.name.localeCompare(b.name));
    }
    return [...results].sort((a, b) => a.id - b.id);
  }

  @action
  updateSearch(event) {
    const value = event.target.value;
    clearTimeout(this.#searchTimeout);
    this.#searchTimeout = setTimeout(() => {
      this.searchTerm = value;
    }, 300);
  }

  @action
  updateSort(event) {
    this.sortBy = event.target.value;
  }

  @action
  nextPage() {
    if (this.isLastPage) return;
    this.router.transitionTo('index', {
      queryParams: { page: this.currentPage + 1 },
    });
  }

  @action
  previousPage() {
    if (this.isFirstPage) return;
    this.router.transitionTo('index', {
      queryParams: { page: this.currentPage - 1 },
    });
  }

  <template>
    <FeaturedRotator />

    <div class="list-controls">
      <label class="visually-hidden" for="pokemon-search">Search</label>
      <input
        id="pokemon-search"
        type="text"
        placeholder="Search all 151 Pokémon"
        class="search-input"
        {{on "input" this.updateSearch}}
      />
      {{#unless this.searchTerm}}
        <label class="visually-hidden" for="pokemon-sort">Sort by</label>
        <select
          id="pokemon-sort"
          class="sort-select"
          {{on "change" this.updateSort}}
        >
          <option value="id">Sort by ID</option>
          <option value="name">Sort by name</option>
        </select>
      {{/unless}}
    </div>

    {{#if this.searchResults}}
      {{#if this.searchResults.length}}
        <div class="pokemon-grid">
          {{#each this.searchResults as |pokemon|}}
            <PokemonCard @pokemon={{pokemon}} />
          {{/each}}
        </div>
      {{else}}
        <p class="empty-state">No Pokémon match your search.</p>
      {{/if}}
    {{else}}
      <div class="pokemon-grid">
        {{#each this.filteredPokemon as |pokemon|}}
          <PokemonCard @pokemon={{pokemon}} />
        {{/each}}
      </div>

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
          {{this.currentPage}}
          of
          {{this.totalPages}}
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
    {{/if}}
  </template>
}
