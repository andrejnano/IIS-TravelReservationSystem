<template>
  <v-card class="layout column" light>

      <!-- TOOLBAR -->
      <v-toolbar card prominent>
        <v-toolbar-title><v-icon>mdi-airplane-takeoff</v-icon>&nbsp;&nbsp;Flights table (200 newest flights)</v-toolbar-title>
      </v-toolbar>

        <!-- SEARCH FORM -->
        <v-flex ma-2 xs11 sm8 md6 lg4 v-if="this.actualFlight == ''">
          <v-form ref="form" v-model="valid" lazy-validation>
                <v-combobox clearable
                  v-model="searchAirline"
                  label="Airline"
                  :items="airlineIDs"
                  required
                ></v-combobox>
                <v-combobox clearable
                  v-model="searchOrigin"
                  label="Origin airport code"
                  :items="airportIDs"
                  required
                ></v-combobox>
                <v-combobox clearable
                  v-model="searchDestination"
                  label="Destination airport code"
                  :items="airportIDs"
                  required
                ></v-combobox>
                <v-btn @click="search"><v-icon light>mdi-magnify</v-icon>search</v-btn>
          </v-form>
        </v-flex>

        <!-- EDIT FORM -->
        <v-flex ma-2 xs11 sm8 md6 lg4 v-if="this.actualFlight != ''">
          <main role="main">
            <p class="subheading"> <b> {{ this.actualFlight }} </b></p>
            <p class="subheading"> <b> {{ this.origin}} -> {{ this.destination}} </b></p>
            <p class="subheading"> Airline: <b> {{ this.airline }} </b></p>
            <p class="subheading"> Airplane: <b> {{ this.airplane }} </b></p>
          </main>
          <v-btn @click="cancel">back</v-btn>
          <v-btn color="red" @click="deleteFlight">
              <v-icon light>mdi-delete</v-icon>delete flight
          </v-btn>
        </v-flex>


          <main role="main">
            <p class="subheading font-weight-regular"> {{this.message}}</p>
          </main>
          <main role="main">
            <p class="subheading font-weight-regular"> {{this.searchMessage}}</p>
          </main>

            <!-- FLIGHT LIST -->
            <v-list-tile v-for="flight in flights" :key="flight.flight_number" avatar ripple>
              <v-list-tile-content>
                <v-list-tile-title> {{ flight.flight_number }} &nbsp;|&nbsp; <b>{{ flight.origin }} → {{ flight.destination }}</b> &nbsp;|&nbsp; {{ flight.airline }} (plane {{ flight.airplane }})</v-list-tile-title>
                <v-list-tile-sub-title > {{ flight.departure_time }} - {{ flight.arrival_time }}</v-list-tile-sub-title>
              </v-list-tile-content>
              <v-spacer></v-spacer>
              <v-btn dark color="green"
              @click="editFlight(flight)"
              large>EDIT</v-btn>
            </v-list-tile>

  </v-card>
</template>

<script>

import '@mdi/font/css/materialdesignicons.css';
import moment from 'moment';

import DebugBox from './DebugBox.vue';

import { library } from '@fortawesome/fontawesome-svg-core'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

import axios from 'axios'

export default {
  name: 'searchFlightForm',
  data() {
    return {
      origin: "",
      destination: "",
      departureTime: "",
      arrivalTime: "",
      airline: "",
      airplane: "",
      message: "",
      searchMessage: "",
      actualFlight: "",
      deletedFlight: "",
      flights: [],
      airportIDs: [],
      airlineIDs: [],
      toggleSearch: 0,
      searchString: "",
      searchAirline: null,
      searchOrigin: null,
      searchDestination: null,
      rules: {
          required: value => !!value || 'Required.',
          min: v => (v && v.length >= 8) || 'Min 8 characters'
      },
      nameRules: [
        v => !!v || 'Name is required',
        v => (v && v.length <= 10) || 'Name must be less than 10 characters'
      ],
      valid: true
    }
  },
  created () {
    axios.get('/api/new_flights', {
        }).then((response) => {
            if (response.status == 200) {
              this.flights = response.data;
              this.searchMessage = "All flights";
            } else {
              this.message = "Error - not able to get flights";
            }
          })
          .catch((error) => {
            this.message = "Error - not able to get flights";
            console.log("ERR: " + error);
          });
    axios.get('/api/airports').then(res => {
          if (this.airportIDs.length == 0) {
            let rd = res.data;
            for (var i = 0; i < rd.length; i++) {
              this.airportIDs.push(rd[i].airport_code.concat(" - ").concat(rd[i].city));
            }
          }
      });

    axios.get('/api/airlines').then(res => {
          if (this.airlineIDs.length == 0) {
            let rd = res.data;
            for (var i = 0; i < rd.length; i++) {
              this.airlineIDs.push(rd[i].airline.concat(" - ").concat(rd[i].full_name));
            }
          }
      });
  },
  methods: {
    search() {
      console.log(this.searchAirline + " " + this.searchOrigin + " " + this.searchDestination);
      axios.get('/api/new_flights', {
        }).then((response) => {
            if (response.status == 200) {
                this.flights = [];
                response.data.forEach(flight => {
                    if(this.searchAirline == null || this.searchAirline.substring(0,2) == flight.airline){
                      if(this.searchOrigin == null || this.searchOrigin.substring(0,3) == flight.origin){
                        if(this.searchDestination == null || this.searchDestination.substring(0,3) == flight.destination){
                          this.flights.push(flight);
                        }
                      }
                    }
                });
                this.searchMessage = "Flights of " + (this.searchAirline != null ?  "'"+this.searchAirline.substring(5)+"'" : "any airline");
                this.searchMessage += " from " + (this.searchOrigin != null ? "'"+this.searchOrigin.substring(6)+"'" : "any airport");
                this.searchMessage += " to " + (this.searchDestination != null ? "'"+this.searchDestination.substring(6)+"'" : "any airport");
                if(this.searchAirline == null && this.searchOrigin == null && this.searchDestination == null){
                  this.searchMessage = "All flights";
                }
            } else {
              this.message = "Error - not able to get flights";
            }
          })
          .catch((error) => {
            this.message = "Error - not able to get flights";
            console.log("ERR: " + error);
          });
    },
    editFlight(editedFlight) {
      this.actualFlight = editedFlight.flight_number;
      this.origin = editedFlight.origin;
      this.destination = editedFlight.destination;
      this.departureTime = editedFlight.departure_time;
      this.arrivalTime = editedFlight.arrival_time;
      this.airline = editedFlight.airline;
      this.airplane = editedFlight.airplane;

    },
    cancel() {
      this.actualFlight = "";
    },
    deleteFlight() {
      this.deletedFlight = this.actualFlight + " (" + this.orogin + " → " + this.destination + ")";
      axios.post('/api/delete_flight', {
            flight_number: this.actualFlight,
        }).then((response) => {
            if (response.status == 200) {
              this.message = "Flight " + this.fullName + " was successfully deleted";
            } else {
              this.message = "Error - flight was not deleted";
            }
            this.search();
          })
          .catch((error) => {
            this.message = "Error - flight was not deleted";
            console.log("ERR: " + error);
          });
      this.actualFlight = "";
    }
  },
  components: {
    'debug-box': DebugBox,
    'font-awesome-icon': FontAwesomeIcon
  }
}

</script>

<style lang="scss">

// global stylesheet
// @import '../design/style';

/* Enter and leave animations can use different */
/* durations and timing functions.              */
.slide-fade-enter-active {
  transition: all .3s ease;
}
.slide-fade-leave-active {
  transition: all .8s cubic-bezier(1.0, 0.5, 0.8, 1.0);
}
.slide-fade-enter, .slide-fade-leave-to
/* .slide-fade-leave-active below version 2.1.8 */ {
  transform: translateX(10px);
  opacity: 0;
}

.custom-loader {
    animation: loader 1s infinite;
    display: flex;
  }
  @-moz-keyframes loader {
    from {
      transform: rotate(0);
    }
    to {
      transform: rotate(360deg);
    }
  }
  @-webkit-keyframes loader {
    from {
      transform: rotate(0);
    }
    to {
      transform: rotate(360deg);
    }
  }
  @-o-keyframes loader {
    from {
      transform: rotate(0);
    }
    to {
      transform: rotate(360deg);
    }
  }
  @keyframes loader {
    from {
      transform: rotate(0);
    }
    to {
      transform: rotate(360deg);
    }
  }
</style>
