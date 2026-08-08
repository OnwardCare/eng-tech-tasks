import { LinkTo } from '@ember/routing';

const isCurrent = (entry, currentId) => entry.id === currentId;

<template>
  {{#if @stages.length}}
    <ol class="evolution-chain">
      {{#each @stages as |stage index|}}
        <li class="evolution-stage">
          {{#if index}}
            <span class="evolution-arrow" aria-hidden="true">→</span>
          {{/if}}
          <ul class="evolution-branches">
            {{#each stage as |entry|}}
              <li>
                <LinkTo
                  @route="pokemon"
                  @model={{entry.id}}
                  class="evolution-link
                    {{if (isCurrent entry @currentId) 'is-current'}}"
                  aria-current={{if (isCurrent entry @currentId) "page"}}
                >
                  {{#if entry.sprite}}
                    <img src={{entry.sprite}} alt="" class="evolution-sprite" />
                  {{/if}}
                  <span class="evolution-name">{{entry.name}}</span>
                </LinkTo>
              </li>
            {{/each}}
          </ul>
        </li>
      {{/each}}
    </ol>
  {{else}}
    <p class="empty-state">This Pokémon does not evolve.</p>
  {{/if}}
</template>
