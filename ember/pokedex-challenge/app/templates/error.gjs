import { pageTitle } from 'ember-page-title';

<template>
  {{pageTitle "Error"}}

  <div class="error-state">
    <h1>Something went wrong</h1>
    <p>
      We couldn't load that page. Check your connection and try again.
    </p>
  </div>
</template>
