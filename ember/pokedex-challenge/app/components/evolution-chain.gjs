import { LinkTo } from '@ember/routing';

<template>
  <div class="evolution-chain">
    {{#if @stages.length}}
      {{#each @stages as |stage|}}
        <div class="evolution-stage">
          {{#each stage.pokemons as |pokemon|}}
            <LinkTo
              @route="pokemon"
              @model={{pokemon.id}}
              class="evolution-stage-link"
            >
              {{pokemon.name}}
            </LinkTo>
          {{/each}}
        </div>
        {{#unless stage.isLast}}
          <span class="evolution-arrow">&rarr;</span>
        {{/unless}}
      {{/each}}
    {{else}}
      <div class="evolution-placeholder">No evolution data available.</div>
    {{/if}}
  </div>
</template>
