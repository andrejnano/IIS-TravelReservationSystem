<template>
  <v-card class="layout column" light>

      <!-- TOOLBAR -->
      <v-toolbar card prominent>
        <v-toolbar-title><v-icon>mdi-airplane-landing</v-icon>&nbsp;&nbsp;Airports table</v-toolbar-title>
      </v-toolbar>

        <!-- SEARCH FORM -->
        <v-flex ma-2 xs11 sm8 md6 lg4>
          <v-btn-toggle v-model="toggleSearch" mandatory>
            <v-btn flat>Airport code</v-btn>
            <v-btn flat>City</v-btn>
            <v-btn flat>Country</v-btn>
          </v-btn-toggle>
          <v-form ref="form" v-model="valid" lazy-validation>
                <v-text-field
                  v-model="searchString"
                  label="contains"
                ></v-text-field>
                <v-btn @click="search"><v-icon light>mdi-magnify</v-icon>search</v-btn>
          </v-form>
        </v-flex>

          <main role="main">
            <p class="subheading font-weight-regular"> {{this.message}}</p>
          </main>

            <!-- AIRPORT LIST -->
            <v-list-tile v-for="airport in airports" :key="airport.airport_code" avatar ripple>
              <v-list-tile-content>
                <v-list-tile-title> {{ airport.airport_code }}  | {{ airport.city }} </v-list-tile-title>
                <v-list-tile-sub-title > {{ airport.country }} </v-list-tile-sub-title>
              </v-list-tile-content>
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
  name: 'ChangePasswordForm',
  data() {
    return {
      message: "",
      airports: [],
      toggleSearch: 0,
      searchString: "",
      valid: true
    }
  },
  created () {
    axios.get('/api/airports', {
        }).then((response) => {
            if (response.status == 200) {
              this.airports = response.data;
              this.message = "Airports";
            } else {
              this.message = "Error - not able to get airports";
            }
          })
          .catch((error) => {
            this.message = "Error - not able to get airports";
            console.log("ERR: " + error);
          });
  },
  methods: {
    search() {
      axios.get('/api/airports', {
        }).then((response) => {
            if (response.status == 200) {
                this.airports = [];
                if(this.toggleSearch == 0) {
                  response.data.forEach(airport => {
                    if(airport.airport_code.search(this.searchString) > -1){
                      this.airports.push(airport);
                    }
                  });
                  this.message = "Airports containing '" + this.searchString + "' in code";
                } else if (this.toggleSearch == 1) {
                  response.data.forEach(airport => {
                    if(airport.city.search(this.searchString) > -1){
                      this.airports.push(airport);
                    }
                  });
                  this.message = "Airports containing '" + this.searchString + "' in city";
                } else {
                  response.data.forEach(airport => {
                    if(airport.country.search(this.searchString) > -1){
                      this.airports.push(airport);
                    }
                  });
                  this.message = "Airports containing '" + this.searchString + "' in country";
                }
            } else {
              this.message = "Error - not able to get airports";
            }
          })
          .catch((error) => {
            this.message = "Error - not able to get airports";
            console.log("ERR: " + error);
          });
    },
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
