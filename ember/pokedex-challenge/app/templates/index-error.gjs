import { LinkTo } from '@ember/routing';

<template>
  <div class="error-state" role="alert">
    <p>{{@model.message}}</p>
    <LinkTo @route="index" class="page-button">Try again</LinkTo>
  </div>
</template>
