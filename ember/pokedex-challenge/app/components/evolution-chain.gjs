import { LinkTo } from '@ember/routing';

<template>
  {{#if @chain.length}}
    <div class="evolution-chain">
      {{#each @chain as |stage|}}
        {{#if stage.separator}}
          <span class="evo-sep">{{stage.separator}}</span>
        {{/if}}
        <LinkTo @route="pokemon" @model={{stage.id}} class="evo-stage">
          {{stage.name}}
        </LinkTo>
      {{/each}}
    </div>
  {{/if}}
</template>
