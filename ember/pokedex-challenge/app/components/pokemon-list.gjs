import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { hash } from '@ember/helper';
import { LinkTo } from '@ember/routing';
import FeaturedRotator from 'pokedex-challenge/components/featured-rotator';
import PokemonCard from 'pokedex-challenge/components/pokemon-card';

const isSelected = (value, current) => value === current;

export default class PokemonList extends Component {
  @tracked searchTerm = '';
  @tracked sortBy = 'id';

  // Search and sort apply to the current page only; the API paginates and we
  // do not load all 151 up front.
  get visiblePokemon() {
    const term = this.searchTerm.trim().toLowerCase();
    const results = term
      ? this.args.pokemon.filter((p) => p.name.toLowerCase().includes(term))
      : [...this.args.pokemon];

    return this.sortBy === 'name'
      ? results.sort((a, b) => a.name.localeCompare(b.name))
      : results.sort((a, b) => a.id - b.id);
  }

  get hasPrevious() {
    return this.args.page > 1;
  }

  get hasNext() {
    return this.args.page < this.args.pageCount;
  }

  get previousPage() {
    return this.args.page - 1;
  }

  get nextPage() {
    return this.args.page + 1;
  }

  @action
  updateSearch(event) {
    this.searchTerm = event.target.value;
  }

  @action
  updateSort(event) {
    this.sortBy = event.target.value;
  }

  <template>
    <FeaturedRotator />

    <div class="list-controls">
      <label class="visually-hidden" for="pokemon-search">Search by name</label>
      <input
        id="pokemon-search"
        type="text"
        placeholder="Search by name"
        value={{this.searchTerm}}
        class="search-input"
        {{on "input" this.updateSearch}}
      />
      <label class="visually-hidden" for="pokemon-sort">Sort by</label>
      <select
        id="pokemon-sort"
        class="sort-select"
        {{on "change" this.updateSort}}
      >
        <option value="id" selected={{isSelected "id" this.sortBy}}>
          Sort by ID
        </option>
        <option value="name" selected={{isSelected "name" this.sortBy}}>
          Sort by name
        </option>
      </select>
    </div>

    {{#if this.visiblePokemon.length}}
      <div class="pokemon-grid">
        {{#each this.visiblePokemon key="id" as |pokemon|}}
          <PokemonCard @pokemon={{pokemon}} />
        {{/each}}
      </div>
    {{else}}
      <p class="empty-state">No Pokémon on this page match your search.</p>
    {{/if}}

    <div class="pagination">
      {{#if this.hasPrevious}}
        <LinkTo
          @route="index"
          @query={{hash page=this.previousPage}}
          class="page-button"
        >
          Previous
        </LinkTo>
      {{else}}
        <button type="button" class="page-button" disabled>Previous</button>
      {{/if}}

      <span class="page-status">
        Page
        {{@page}}
        of
        {{@pageCount}}
      </span>

      {{#if this.hasNext}}
        <LinkTo
          @route="index"
          @query={{hash page=this.nextPage}}
          class="page-button"
        >
          Next
        </LinkTo>
      {{else}}
        <button type="button" class="page-button" disabled>Next</button>
      {{/if}}
    </div>
  </template>
}
