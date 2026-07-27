import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import { modifier } from 'ember-modifier';
import FeaturedRotator from 'pokedex-challenge/components/featured-rotator';
import PokemonCard from 'pokedex-challenge/components/pokemon-card';
import { toCardShape } from 'pokedex-challenge/utils/pokemon';

const PAGE_SIZE = 20;

export default class PokemonList extends Component {
  @service pokeData;

  @tracked searchTerm = '';
  @tracked sortBy = 'id';
  @tracked offset = 0;
  @tracked pageCards = [];
  @tracked isLoading = false;
  @tracked error = null;

  // args.pokemon is the full, lightweight { id, name } list for all of Gen 1
  // (see IndexRoute). Filtering/sorting happens over that whole set so
  // search isn't limited to whichever page happens to be on screen.
  get filteredEntries() {
    let results = this.args.pokemon;
    if (this.searchTerm) {
      const term = this.searchTerm.toLowerCase();
      results = results.filter((p) => p.name.toLowerCase().includes(term));
    }
    results = results.slice();
    if (this.sortBy === 'name') {
      results.sort((a, b) => a.name.localeCompare(b.name));
    } else {
      results.sort((a, b) => a.id - b.id);
    }
    return results;
  }

  get pageEntries() {
    return this.filteredEntries.slice(this.offset, this.offset + PAGE_SIZE);
  }

  // Identifies which page of entries is currently visible so the loader
  // modifier below only re-fetches when that actually changes.
  get pageKey() {
    return this.pageEntries.map((entry) => entry.id).join(',');
  }

  get canGoPrevious() {
    return this.offset > 0 && !this.isLoading;
  }

  get canGoNext() {
    return (
      this.offset + PAGE_SIZE < this.filteredEntries.length && !this.isLoading
    );
  }

  get previousDisabled() {
    return !this.canGoPrevious;
  }

  get nextDisabled() {
    return !this.canGoNext;
  }

  loadOnChange = modifier((_element, [pageKey]) => {
    if (pageKey) {
      this.loadPageDetails(pageKey);
    } else {
      this.pageCards = [];
    }
  });

  async loadPageDetails(pageKey) {
    const entries = this.pageEntries;
    this.isLoading = true;
    this.error = null;

    try {
      const details = await Promise.all(
        entries.map((entry) => this.pokeData.fetchPokemon(entry.id)),
      );

      // Ignore a slower, now-stale page load resolving after the user has
      // already paged/searched/sorted again.
      if (pageKey !== this.pageKey) {
        return;
      }

      this.pageCards = details.map(toCardShape);
    } catch {
      this.error = 'Could not load this page of Pokémon.';
    } finally {
      this.isLoading = false;
    }
  }

  @action
  updateSearch(event) {
    this.searchTerm = event.target.value;
    this.offset = 0;
  }

  @action
  updateSort(event) {
    this.sortBy = event.target.value;
    this.offset = 0;
  }

  @action
  nextPage() {
    if (!this.canGoNext) {
      return;
    }
    this.offset = this.offset + PAGE_SIZE;
  }

  @action
  previousPage() {
    if (!this.canGoPrevious) {
      return;
    }
    this.offset = Math.max(0, this.offset - PAGE_SIZE);
  }

  <template>
    <FeaturedRotator />

    <div class="list-controls" {{this.loadOnChange this.pageKey}}>
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
    {{else if this.filteredEntries.length}}
      <div class="pokemon-grid">
        {{#each this.pageCards as |pokemon|}}
          <PokemonCard @pokemon={{pokemon}} />
        {{/each}}
      </div>
    {{else}}
      <p class="empty-state">No Pokémon match &quot;{{this.searchTerm}}&quot;.</p>
    {{/if}}

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
