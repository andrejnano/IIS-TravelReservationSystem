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
    <template>
      <v-toolbar-items v-if="isLoggedIn">
        <v-btn @click="logout" flat>Log out</v-btn>
      </v-toolbar-items>
      <v-toolbar-items v-else>
        <v-btn to="/login" flat>Sign In</v-btn>
        <v-btn to="/register" flat color='accent'>Register</v-btn>
      </v-toolbar-items>
    </template>
  </v-toolbar>
</template>

<script>

import axios from 'axios';

export default {
  data() {
    return {
      isLoggedIn: true,
    }
  },
  updated() {
    axios.get('/api/session').then((response) => {

      if (response.status.code == 200)
      {
        this.isLoggedIn = true;
      }
      else
      {
        this.isLoggedIn = false;
      }

    });
  },
  methods: {
    logout() {
      axios.post('/api/logout').then((response) => {
        console.log(response);
        this.isLoggedIn = false;
      });
    }
  }
}
</script>

<style lang="scss" scoped>
  .primary-nav {
    background-color: #222;
  }
</style>

