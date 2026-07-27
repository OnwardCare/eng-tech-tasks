import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import FeaturedRotator from 'pokedex-challenge/components/featured-rotator';
import PokemonCard from 'pokedex-challenge/components/pokemon-card';
import { toCardShape } from 'pokedex-challenge/utils/pokemon';

const GEN_1_COUNT = 151;
const PAGE_SIZE = 20;

export default class PokemonList extends Component {
  @service pokeData;

  @tracked searchTerm = '';
  @tracked sortBy = 'id';
  @tracked offset = 0;
  @tracked pageItems = null;
  @tracked isLoading = false;
  @tracked error = null;

  get filteredPokemon() {
    // slice() before sort/filter so we never mutate the cached page array.
    let results = (this.pageItems ?? this.args.pokemon).slice();
    if (this.searchTerm) {
      const term = this.searchTerm.toLowerCase();
      results = results.filter((p) => p.name.toLowerCase().includes(term));
    }
    if (this.sortBy === 'name') {
      results.sort((a, b) => a.name.localeCompare(b.name));
    } else {
      results.sort((a, b) => a.id - b.id);
    }
    return results;
  }

  get canGoPrevious() {
    return this.offset > 0 && !this.isLoading;
  }

  get canGoNext() {
    return this.offset + PAGE_SIZE < GEN_1_COUNT && !this.isLoading;
  }

  get previousDisabled() {
    return !this.canGoPrevious;
  }

  get nextDisabled() {
    return !this.canGoNext;
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
  nextPage() {
    if (!this.canGoNext) {
      return;
    }
    this.loadPage(this.offset + PAGE_SIZE);
  }

  @action
  previousPage() {
    if (!this.canGoPrevious) {
      return;
    }
    this.loadPage(Math.max(0, this.offset - PAGE_SIZE));
  }

  async loadPage(offset) {
    this.isLoading = true;
    this.error = null;

    try {
      const limit = Math.min(PAGE_SIZE, GEN_1_COUNT - offset);
      const list = await this.pokeData.fetchList(offset, limit);
      const details = await Promise.all(
        list.results.map((entry) => this.pokeData.fetchPokemon(entry.name)),
      );
      this.offset = offset;
      this.pageItems = details.map(toCardShape);
    } catch {
      this.error = 'Could not load this page of Pokémon.';
    } finally {
      this.isLoading = false;
    }
  }

  <template>
    <FeaturedRotator />

    <div class="list-controls">
      <label class="search-label" for="pokemon-search">Search by name</label>
      <input
        id="pokemon-search"
        type="text"
        placeholder="Search by name"
        value={{this.searchTerm}}
        class="search-input"
        {{on "input" this.updateSearch}}
      />
      <label class="sort-label" for="pokemon-sort">Sort</label>
      <select
        id="pokemon-sort"
        class="sort-select"
        {{on "change" this.updateSort}}
      >
        <option value="id">Sort by ID</option>
        <option value="name">Sort by name</option>
      </select>
    </div>

    {{#if this.error}}
      <p class="list-error">{{this.error}}</p>
    {{/if}}

    <div class="pokemon-grid">
      {{#each this.filteredPokemon as |pokemon|}}
        <PokemonCard @pokemon={{pokemon}} />
      {{/each}}
    </div>

    <div class="pagination">
      <button
        type="button"
        class="page-button"
        disabled={{this.previousDisabled}}
        {{on "click" this.previousPage}}
      >
        Previous
      </button>
      <button
        type="button"
        class="page-button"
        disabled={{this.nextDisabled}}
        {{on "click" this.nextPage}}
      >
        Next
      </button>
    </div>
  </template>
}
