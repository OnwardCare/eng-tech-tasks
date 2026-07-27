import { LinkTo } from '@ember/routing';

<template>
  <div class="route-error">
    <p>Something went wrong loading this page.</p>
    <LinkTo @route="index" class="page-button">Back to the Pokédex</LinkTo>
  </div>
</template>
