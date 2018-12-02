<template>
  <v-content>
    <loading :active.sync="isLoading" :can-cancel="true" :on-cancel="loadingCancel" :is-full-page="fullPage"></loading>
    <v-container fluid>
      <v-layout ma-2 row align-start>

        <v-layout ma-2 column align-start>
          <v-flex ma-2 xs11 sm9 md7 lg5>
            <main role="main">
              <h1 class="display-2 mb-3">Edit database</h1><br>
            </main>
          </v-flex>

          <!-- USER - x1 -->
          <v-list-tile avatar ripple>
            <v-list-tile-content>
              <v-list-tile-title> <h2>USERS</h2> </v-list-tile-title>
            </v-list-tile-content>
            <v-btn dark color="green" @click="addUser">ADD</v-btn>    
            <v-btn dark color="blue" @click="searchUser">SEARCH</v-btn>
          </v-list-tile>

          <!-- FLIGHT - x2 -->
          <v-list-tile avatar ripple>
            <v-list-tile-content>
              <v-list-tile-title> <h2>FLIGHTS</h2> </v-list-tile-title>
            </v-list-tile-content>
            <v-btn dark color="green" @click="addFlight">ADD</v-btn>    
            <v-btn dark color="blue" @click="searchFlight">SEARCH</v-btn>
          </v-list-tile>

          <!-- AIRLINE - x3 -->
          <v-list-tile avatar ripple>
            <v-list-tile-content>
              <v-list-tile-title> <h2>AIRLINES</h2> </v-list-tile-title>
            </v-list-tile-content>
            <v-btn dark color="green" @click="addAirline">ADD</v-btn>    
            <v-btn dark color="blue" @click="searchAirline">SEARCH</v-btn>
          </v-list-tile>

          <!-- AIRPLANE - x4 -->
          <v-list-tile avatar ripple>
            <v-list-tile-content>
              <v-list-tile-title> <h2>AIRPLANES</h2> </v-list-tile-title>
            </v-list-tile-content>
            <v-btn dark color="green" @click="addAirplane">ADD</v-btn>    
            <v-btn dark color="blue" @click="searchAirplane">SEARCH</v-btn>
          </v-list-tile>

          <!-- AIRPORTS - x5 -->
          <v-list-tile avatar ripple>
            <v-list-tile-content>
              <v-list-tile-title> <h2>AIRPORTS</h2> </v-list-tile-title>
            </v-list-tile-content>
            <v-btn dark color="green" @click="addAirport">ADD</v-btn>    
            <v-btn dark color="blue" @click="searchAirport">SEARCH</v-btn>
          </v-list-tile>

        </v-layout>



       <!-- codes: -->
       <!-- add: 1x   |   search: 2x -->
       <!-- users x1  |  flights: x2  |  airlines: x3  |  airplanes: x4  |  airports: x5 -->
        <v-layout column>
          <v-flex xs12 sm12 md12 lg12>
            <add-user-form v-if="adminState == 11"/>
          </v-flex>

          <v-flex xs12 sm12 md12 lg12>
            <add-flight-form v-if="adminState == 12"/>
          </v-flex>

          <v-flex xs12 sm12 md12 lg12>
            <add-airline-form v-if="adminState == 13"/>
          </v-flex>

          <v-flex xs12 sm12 md12 lg12>
            <add-airplane-form v-if="adminState == 14"/>
          </v-flex>
            
            <v-flex xs12 sm12 md12 lg12>
            <add-airport-form v-if="adminState == 15"/>
            </v-flex>

          <v-flex xs12 sm12 md12 lg12>
            <search-user-form v-if="adminState == 21"/>
          </v-flex>
        </v-layout>

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

  import AddUserForm from '../components/AddUserForm.vue';
  import AddFlightForm from '../components/AddFlightForm.vue';
  import AddAirportForm from '../components/AddAirportForm.vue';
  import AddAirplaneForm from '../components/AddAirplaneForm.vue';
  import AddAirlineForm from '../components/AddAirlineForm.vue';

  import SearchUserForm from '../components/SearchUserForm.vue';

  import axios from 'axios'

  library.add(faSpinner)
  dom.watch() // This will kick of the initial replacement of i to svg tags and configure a MutationObserver

  export default {
    name: 'ProfileView',
    data() {
      return {
        isLoading: false,
        fullPage: true,
        adminState: 0
      }
    },
    methods: {
      loadingCancel() {
        console.log('User cancelled the loader.');
      },
      /**
       * codes:
       *    add: 1x   |   search: 2x
       *    users x1  |  flights: x2  |  airlines: x3  |  airplanes: x4  |  airports: x5
       */
      addUser() {
        if(this.adminState == 11){
          this.adminState = 0;
        }
        else{
          this.adminState = 11;
        }
      },
      addFlight() {
        if(this.adminState == 12){
          this.adminState = 0;
        }
        else{
          this.adminState = 12;
        }
      },
      addAirline() {
        if(this.adminState == 13){
          this.adminState = 0;
        }
        else{
          this.adminState = 13;
        }
      },
      addAirplane() {
        if(this.adminState == 14){
          this.adminState = 0;
        }
        else{
          this.adminState = 14;
        }
      },
      addAirport() {
        if(this.adminState == 15){
          this.adminState = 0;
        }
        else{
          this.adminState = 15;
        }
      },
      searchUser() {
        if(this.adminState == 21){
          this.adminState = 0;
        }
        else{
          this.adminState = 21;
        }
      },
      searchFlight() {
        if(this.adminState == 22){
          this.adminState = 0;
        }
        else{
          this.adminState = 22;
        }
      },
      searchAirline() {
        if(this.adminState == 23){
          this.adminState = 0;
        }
        else{
          this.adminState = 23;
        }
      },
      searchAirplane() {
        if(this.adminState == 24){
          this.adminState = 0;
        }
        else{
          this.adminState = 24;
        }
      },
      searchAirport() {
        if(this.adminState == 25){
          this.adminState = 0;
        }
        else{
          this.adminState = 25;
        }
      },
    },
    components: {
      'font-awesome-icon': FontAwesomeIcon,
      'add-user-form': AddUserForm,
      'add-flight-form': AddFlightForm,
      'add-airline-form': AddAirlineForm,
      'add-airport-form': AddAirportForm,
      // 'add-airplane-form': AddAirplaneForm,
      // 'search-airline-form': SearchUserForm,
      // 'search-airplane-form': SearchUserForm,
      // 'search-airport-form': SearchUserForm,
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
