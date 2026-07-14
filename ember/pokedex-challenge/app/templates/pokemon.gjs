import { pageTitle } from 'ember-page-title';
import PokemonDetail from 'pokedex-challenge/components/pokemon-detail';

<template>
  {{pageTitle "Pokémon"}}
  <PokemonDetail @model={{@model}} />
</template>
