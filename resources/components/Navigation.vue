<template>
  <b-navbar toggleable="md" class="navbar-expand-lg navbar-light bg-light">

    <b-navbar-toggle target="nav_collapse"></b-navbar-toggle>
    <b-navbar-brand :to="{name: 'landing'}" exact active class="d-inline-block align-top">
      Home
    </b-navbar-brand>

    <b-collapse is-nav id="nav_collapse">
      <b-navbar-nav>
        <b-nav-item :to="{name: 'login'}">Login</b-nav-item>
        <b-nav-item :to="{name: 'register'}">Register</b-nav-item>
      </b-navbar-nav>

      <b-navbar-nav class="ml-auto">
        <b-nav-item :to="{name: 'help'}">How to search for flights?</b-nav-item>
        <b-nav-item :to="{name: 'faq'}">FAQ</b-nav-item>
        <b-nav-item :to="{name: 'contact'}">Contact</b-nav-item>
      </b-navbar-nav>
    </b-collapse>
  </b-navbar>
</template>

<script>

  import 'bootstrap/dist/css/bootstrap.css';
  import 'bootstrap-vue/dist/bootstrap-vue.css';

export default {

}
</script>

<style lang="scss" scoped>
  .primary-nav {
    background-color: #222;
  }
</style>

