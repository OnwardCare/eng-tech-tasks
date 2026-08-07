import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { LinkTo } from '@ember/routing';
import FavoriteButton from 'pokedex-challenge/components/favorite-button';
import TypeBadge from 'pokedex-challenge/components/type-badge';

export default class PokemonCard extends Component {
  @tracked spriteFailed = false;

  get showSprite() {
    return Boolean(this.args.pokemon.sprite) && !this.spriteFailed;
  }

  @action
  handleSpriteError() {
    this.spriteFailed = true;
  }

  <template>
    <div class="pokemon-card">
      <FavoriteButton @pokemon={{@pokemon}} />
      <LinkTo @route="pokemon" @model={{@pokemon.id}} class="pokemon-link">
        {{#if this.showSprite}}
          <img
            src={{@pokemon.sprite}}
            alt={{@pokemon.name}}
            class="pokemon-sprite"
            {{on "error" this.handleSpriteError}}
          />
        {{else}}
          <div
            class="pokemon-sprite sprite-placeholder"
            aria-hidden="true"
          >?</div>
        {{/if}}
        <h3 class="pokemon-name">{{@pokemon.name}}</h3>
      </LinkTo>
      <span class="pokemon-id">#{{@pokemon.id}}</span>
      <div class="pokemon-types">
        {{#each @pokemon.types as |type|}}
          <TypeBadge @type={{type}} />
        {{/each}}
      </div>
    </div>
  </template>
}
