import PokemonList from 'pokedex-challenge/components/pokemon-list';

<template>
  <PokemonList
    @pokemon={{@model.pokemon}}
    @page={{@model.page}}
    @pageCount={{@model.pageCount}}
  />
</template>
