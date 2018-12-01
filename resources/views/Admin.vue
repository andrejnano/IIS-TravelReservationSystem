<template>
  <v-content>
    <loading :active.sync="isLoading" :can-cancel="true" :on-cancel="loadingCancel" :is-full-page="fullPage"></loading>
    <v-container fluid>
      <v-layout ma-2 row align-start>

        <v-layout ma-2 column align-start>
          <v-flex ma-2 xs11 sm9 md7 lg5>
            <main role="main">
              <h1 class="display-2 font-weight-bold mb-3">Edit database</h1><br>
            </main>
          </v-flex>

          <v-flex>
              <!-- ADD USER - 1 -->
              <v-btn color="info" @click="addUser" large>
                Add user
                <span slot="submitLoader" class="custom-loader">
                  <v-icon light>cached</v-icon>
                </span>
              </v-btn>
          </v-flex>

          <v-flex>
              <!-- ADD FLIGHT - 2 -->
              <v-btn color="info" @click="addFlight" large>
                Add flight
                <span slot="submitLoader" class="custom-loader">
                  <v-icon light>cached</v-icon>
                </span>
              </v-btn>
          </v-flex>

          <v-flex>
              <!-- ADD AIRLINE - 3 -->
              <v-btn color="info" @click="addAirline" large>
                Add airline
                <span slot="submitLoader" class="custom-loader">
                  <v-icon light>cached</v-icon>
                </span>
              </v-btn>
          </v-flex>

          <v-flex>
              <!-- ADD AIRPLANE - 4 -->
              <v-btn color="info" @click="addAirplane" large>
                Add Airplane
                <span slot="submitLoader" class="custom-loader">
                  <v-icon light>cached</v-icon>
                </span>
              </v-btn>
          </v-flex>

          <v-flex>
              <!-- ADD AIRPORT - 5 -->
              <v-btn color="info" @click="addAirport" large>
                Add airport
                <span slot="submitLoader" class="custom-loader">
                  <v-icon light>cached</v-icon>
                </span>
              </v-btn>


          </v-flex>

        </v-layout>


        <v-layout column>
          <v-flex xs12 sm12 md12 lg12>
            <add-user-form v-if="adminState == 1"/>
          </v-flex>

          <v-flex xs12 sm12 md12 lg12>
            <add-flight-form v-if="adminState == 2"/>
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
        //results: [],
        /*message: "",
        newFlightFormVisible: false,
        showPasswordField: false,
        origin: '',
        destination: '',
        departure_time: '',
        arrival_time: '',
        airplane: '',
        airline: '',*/

        /*rules: {
          required: value => !!value || 'Required.',
          min: v => v.length >= 8 || 'Min 8 characters'
        },*/
        //valid: true,
        //user: []
      }
    },
    methods: {
      loadingCancel() {
        console.log('User cancelled the loader.');
      },
      addUser() {
        if(this.adminState == 1){
          this.adminState = 0;
        }
        else{
          this.adminState = 1;
        }
      },
      addFlight() {
        if(this.adminState == 2){
          this.adminState = 0;
        }
        else{
          this.adminState = 2;
        }
      },
      addAirline() {
        if(this.adminState == 3){
          this.adminState = 0;
        }
        else{
          this.adminState = 3;
        }
      },
      addAirplane() {
        if(this.adminState == 4){
          this.adminState = 0;
        }
        else{
          this.adminState = 4;
        }
      },
      addAirport() {
        if(this.adminState == 5){
          this.adminState = 0;
        }
        else{
          this.adminState = 5;
        }
      },



      /*insertFlight() {
        axios.post('/api/add_flight', {
            airplane: this.airplane,
            airline: this.airline,
            departure_time: this.departure_time,
            arrival_time: this.arrival_time,
            origin: this.origin,
            destination: this.destination

        }).then((response) => {
            if (response.status == 200) {
              this.message = "New password was saved!";
            } else {
              this.message = "Error - password was not set";
            }
          })
          .catch((error) => {
            this.message = "Error - password was not set";
            console.log("ERR: " + error);
          });
        this.newFlightFormVisible = false;
        this.password = "";
      },*/
    },
    components: {
      'font-awesome-icon': FontAwesomeIcon,
      'add-user-form': AddUserForm,
      'add-flight-form': AddFlightForm,
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
