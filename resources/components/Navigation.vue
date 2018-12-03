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
      <v-btn flat to="/admin" v-if="isAdmin">Admin page</v-btn>
    </v-toolbar-items>
    <v-spacer></v-spacer>
    <template>
      <v-toolbar-items v-if="isLoggedIn">
      <v-toolbar-items v-if="isAdmin">
        <v-btn flat to="/admin">Edit database</v-btn>
      </v-toolbar-items>
        <v-btn flat to="/profile">Logged in as {{ fullName }}</v-btn>
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
      isLoggedIn: false,
      isAdmin: false,
      firstName: '',
      lastName: ''
    }
  },
  computed: {
    fullName() {
      return this.firstName + ' ' + this.lastName;
    }
  },
  updated() {
    // TODO: change to created
    // TODO: vlozit do samostatnej f.
    axios.get('/api/session').then((response) => {

      if (response.status == 200)
      {
        console.log('session OK');
        this.isLoggedIn = true;
        if (response.data.is_admin)
          this.isAdmin = true;
        this.firstName = response.data.first_name ? response.data.first_name : 'Unknown';
        this.lastName = response.data.last_name ? response.data.last_name : 'Unknown';
        if(response.data.is_admin == 1){
          this.isAdmin = true;
        }
      }
      else
      {
        console.log('session NOT oK');
        this.isLoggedIn = false;
        this.isAdmin = false;
      }

    }).catch((error) => {console.log(error);});
  },
  methods: {
    logout() {
      axios.post('/api/logout').then((response) => {
        console.log(response);
        this.isLoggedIn = false;
        this.isAdmin = false;
        this.$router.go({
          path: '/',
          force: true,
        });
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

