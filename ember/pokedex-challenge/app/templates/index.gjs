import PokemonList from 'pokedex-challenge/components/pokemon-list';

<template>
  <PokemonList
    @pokemon={{@model.pokemon}}
    @allNames={{@model.allNames}}
    @page={{@model.page}}
  />
</template>
