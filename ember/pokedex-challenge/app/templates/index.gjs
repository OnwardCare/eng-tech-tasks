import PokemonList from 'pokedex-challenge/components/pokemon-list';

<template>
  <PokemonList
    @pokemon={{@model.pokemon}}
    @page={{@model.page}}
    @hasNext={{@model.hasNext}}
    @hasPrevious={{@model.hasPrevious}}
  />
</template>
