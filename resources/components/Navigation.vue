<template>
  <v-toolbar app dark color="primary">
    <v-toolbar-items>
      <v-btn flat to="/">
        <v-icon>airplanemode_active</v-icon>
      </v-btn>
    </v-toolbar-items>
    <v-spacer></v-spacer>
    <v-toolbar-items>
      <v-btn flat to="/about">About</v-btn>
      <v-btn flat to="/contact">Contact</v-btn>
    </v-toolbar-items>
    <v-spacer></v-spacer>
    <v-toolbar-items>
      <v-btn to="/login" flat>Sign In</v-btn>
      <v-btn to="/register" flat color='accent'>Register</v-btn>
    </v-toolbar-items>
  </v-toolbar>
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

