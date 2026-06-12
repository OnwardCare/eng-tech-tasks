import { pageTitle } from 'ember-page-title';
import NavBar from 'pokedex-challenge/components/nav-bar';

<template>
  {{pageTitle "Pokédex"}}

  <NavBar />

  <main class="page">
    {{outlet}}
  </main>
</template>
