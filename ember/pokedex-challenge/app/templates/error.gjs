<template>
  <p class="route-error">Something went wrong loading this page.</p>
  {{#if @model.message}}
    <p class="route-error-detail">{{@model.message}}</p>
  {{/if}}
</template>
