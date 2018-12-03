<template>
  <v-toolbar app dark color="primary">
    <v-toolbar-items>
      <v-btn flat to="/">
        <v-icon>airplanemode_active</v-icon>
      </v-btn>
    </v-toolbar-items>
    <v-spacer></v-spacer>
    <v-toolbar-items>
      <v-btn flat to="/about"><v-icon>mdi-information</v-icon>&nbsp;About</v-btn>
      <v-divider vertical></v-divider>
      <v-btn flat to="/contact"><v-icon>mdi-account-box</v-icon>&nbsp;Contact</v-btn>
    </v-toolbar-items>
    <v-spacer></v-spacer>
    <template>
      <v-toolbar-items v-if="isLoggedIn">
      <v-toolbar-items v-if="isAdmin">
        <v-btn flat to="/admin"><v-icon>mdi-database-edit</v-icon>&nbsp;Edit database</v-btn>
        <v-divider vertical></v-divider>
      </v-toolbar-items>
        <v-btn flat to="/profile"><v-icon>mdi-account</v-icon>&nbsp;Logged in as {{ fullName }}</v-btn>
        <v-divider vertical></v-divider>
        <v-btn @click="logout" flat><v-icon>mdi-logout</v-icon>&nbsp;Log out</v-btn>
      </v-toolbar-items>
      <v-toolbar-items v-else>
        <v-btn to="/login" flat><v-icon>mdi-account</v-icon>&nbsp;Sign In</v-btn>
        <v-divider vertical></v-divider>
        <v-btn to="/register" flat color='accent'><v-icon>mdi-account-plus</v-icon>&nbsp;Register</v-btn>
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

