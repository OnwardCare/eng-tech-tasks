import { pageTitle } from 'ember-page-title';
import PokemonDetail from 'pokedex-challenge/components/pokemon-detail';

<template>
  {{pageTitle @model.pokemon.name}}

  <PokemonDetail
    @pokemon={{@model.pokemon}}
    @flavorText={{@model.flavorText}}
    @evolutions={{@model.evolutions}}
  />
</template>
