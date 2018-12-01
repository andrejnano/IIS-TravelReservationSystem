<template>
  <v-content>
    <loading :active.sync="isLoading" :can-cancel="true" :on-cancel="loadingCancel" :is-full-page="fullPage"></loading>
    <v-container fluid>
      <v-layout ma-2 row align-start>
        <v-flex ma-2 xs12 sm10 md8 lg6>
          <main role="main">
            <h1 class="display-2 font-weight-bold mb-3">User information</h1><br>
            <p class="subheading font-weight-regular"> First name:   <b>{{this.user.first_name}}</b></p>
            <p class="subheading font-weight-regular"> Last name:   <b>{{this.user.last_name}}</b></p>
            <p class="subheading font-weight-regular"> E-mail:   <b>{{this.user.email}}</b></p>
          </main>
        </v-flex>
      </v-layout>
    </v-container>
  </v-content>
</template>

<script>

  import Loading from 'vue-loading-overlay';
  import 'vue-loading-overlay/dist/vue-loading.css';
  import {
    library
  } from '@fortawesome/fontawesome-svg-core'
  import {
    faSpinner
  } from '@fortawesome/free-solid-svg-icons'
  import {
    FontAwesomeIcon
  } from '@fortawesome/vue-fontawesome'
  import {
    dom
  } from '@fortawesome/fontawesome-svg-core'

  import axios from 'axios'

  library.add(faSpinner)
  dom.watch() // This will kick of the initial replacement of i to svg tags and configure a MutationObserver

  export default {
    name: 'ProfileView',
    data() {
      return {
        isLoading: false,
        fullPage: true,
        //results: [],
        firstName: "-undef-",
        user: []
      }
    },
    created () {
      axios.get('/api/session').then(res => {
        this.user = res.data;
      });
    },
    methods: {
      loadingCancel() {
        console.log('User cancelled the loader.');
      }
    },
    components: {
      'font-awesome-icon': FontAwesomeIcon,
      Loading
    }
  }

</script>

<style lang="scss">
  // global stylesheet
  // @import '../design/style';

  #loading {
    position: fixed;
    opacity: 0.7;
    z-index: 1000;
    background: #000;
    height: 100%;
    width: 100%;
    display: none;
  }

  #loading.on {
    display: block;
  }

</style>
