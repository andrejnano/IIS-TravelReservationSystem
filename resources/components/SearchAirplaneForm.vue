<template>
  <v-card class="layout column" light>

      <!-- TOOLBAR -->
      <v-toolbar card prominent>
        <v-toolbar-title><v-icon>mdi-airplane</v-icon>&nbsp;&nbsp;Airlines table</v-toolbar-title>
      </v-toolbar>

        <!-- SEARCH FORM -->
        <v-flex ma-2 xs11 sm8 md6 lg4 v-if="this.actualAirplane == 0">
          <v-btn-toggle v-model="toggleSearch" mandatory>
            <v-btn flat>Producer</v-btn>
            <v-btn flat>Model</v-btn>
            <v-btn flat>Airline code</v-btn>
          </v-btn-toggle>
          <v-form ref="form" v-model="valid" lazy-validation>
                <v-text-field
                  v-model="searchString"
                  label="contains"
                ></v-text-field>
                <v-btn @click="search"><v-icon light>mdi-magnify</v-icon>search</v-btn>
          </v-form>
        </v-flex>

        <!-- EDIT FORM -->
        <v-flex ma-2 xs11 sm8 md6 lg4 v-if="this.actualAirplane != 0">
          <main role="main">
            <p class="subheading"> <b> {{ this.producer }} {{ this.model }} </b></p>
            <p class="subheading"> Airline code: <b> {{ this.airline }} </b></p>
            <p class="subheading"> Economy: <b>{{ this.eSeats }}</b> |
                                   Business: <b>{{ this.bSeats }}</b> |
                                   First: <b>{{ this.fSeats }}</b></p>
          </main>
          <v-btn @click="cancel">back</v-btn>
          <v-btn color="red" @click="deleteAirplane">
              <v-icon light>mdi-delete</v-icon>delete airplane
          </v-btn>
        </v-flex>

          <main role="main">
            <p class="subheading" v-html="this.formattedMessage"></p>
          </main>
          <main role="main">
            <p class="subheading" v-html="this.formattedSearchMessage"></p>
          </main>

            <!-- USER LIST -->
            <v-list-tile v-for="airplane in airplanes" :key="airplane.id" avatar ripple>
              <v-list-tile-content>
                <v-list-tile-title> {{ airplane.id }} {{ airplane.producer }} {{ airplane.model }} | {{ airplane.airline }}</v-list-tile-title>
                <v-list-tile-sub-title > Economy: {{ airplane.eclass_seats }} | Business: {{ airplane.bclass_seats }} | First: {{ airplane.fclass_seats }} </v-list-tile-sub-title>
              </v-list-tile-content>
              <v-spacer></v-spacer>
              <v-btn dark color="green"
              @click="editAirplane(airplane)"
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
  name: 'SearchAirplaneForm',
  data() {
    return {
      producer: "",
      model: "",
      airline: "",
      eSeats: 0,
      bSeats: 0,
      fSeats: 0, 
      message: "",
      searchMessage: "",
      actualAirplane: 0,
      fullName: "",
      airplanes: [],
      toggleSearch: 0,
      searchString: "",
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
  computed: {
    formattedMessage() {
      if(this.message.substring(0,5) == "Error"){
        return '<font color="red">' + this.message + '</font>';
      }
      return '<font color="green">' + this.message + '</font>';
    },
    formattedSearchMessage() {
      return '<font color="grey">' + this.searchMessage + '</font>';
    }
  },
  created () {
    axios.get('/api/airplanes', {
        }).then((response) => {
            if (response.status == 200) {
              this.airplanes = response.data;
              this.searchMessage = "All airplanes";
            } else {
              this.message = "Error - not able to get airplanes";
            }
          })
          .catch((error) => {
            this.message = "Error - not able to get airplanes";
            console.log("ERR: " + error);
          });
  },
  methods: {
    editAirplane(editedAirplane) {
      this.actualAirplane = editedAirplane.id;
      this.producer = editedAirplane.producer;
      this.model = editedAirplane.model;
      this.airline = editedAirplane.airline;
      this.eSeats = editedAirplane.eclass_seats;
      this.bSeats = editedAirplane.bclass_seats;
      this.fSeats = editedAirplane.fclass_seats;
    },
    search() {
      axios.get('/api/airplanes', {
        }).then((response) => {
            if (response.status == 200) {
                this.airplanes = [];
                if(this.toggleSearch == 0) {
                  response.data.forEach(airplane => {
                    if(airplane.producer.search(this.searchString) > -1){
                      this.airplanes.push(airplane);
                    }
                  });
                  this.searchMessage = "Airplanes containing '" + this.searchString + "' in producer";
                } else if (this.toggleSearch == 1) {
                  response.data.forEach(airplane => {
                    if(airplane.model.search(this.searchString) > -1){
                      this.airplanes.push(airplane);
                    }
                  });
                  this.searchMessage = "Airplanes containing '" + this.searchString + "' in model";
                } else {
                  response.data.forEach(airplane => {
                    if(airplane.airline.search(this.searchString) > -1){
                      this.airplanes.push(airplane);
                    }
                  });
                  this.searchMessage = "Airplanes containing '" + this.searchString + "' in airline";
                }
                if(this.searchString == ""){
                  this.searchMessage = "All airplanes";
                }
            } else {
              this.message = "Error - not able to get airlines";
            }
          })
          .catch((error) => {
            this.message = "Error - not able to get airlines";
            console.log("ERR: " + error);
          });
    },
    cancel() {
      this.actualAirplane = 0;
    },
    deleteAirplane() {
      this.fullName = this.producer + " " + this.model + " (" + this.airline + ")";
      console.log("Trying to delete "+this.actualAirplane)
      axios.post('/api/delete_airplane', {
            airplane: this.actualAirplane,
        }).then((response) => {
            if (response.status == 200) {
              this.message = "Airplane " + this.fullName + " was successfully deleted";
              this.search();
            } else {
              this.message = "Error - airplane was not deleted";
            }
          })
          .catch((error) => {
            this.message = "Error - airplane was not deleted";
            console.log("ERR: " + error);
          });
       this.actualAirplane = 0;
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
