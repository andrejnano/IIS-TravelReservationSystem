<template>
  <v-card class="layout column" light>

      <!-- TOOLBAR -->
      <v-toolbar card prominent>
        <v-toolbar-title><v-icon>mdi-airplane-takeoff</v-icon>&nbsp;&nbsp;Add new flight</v-toolbar-title>
      </v-toolbar>

          <v-form ref="form" v-model="valid" lazy-validation>

                <v-combobox
                  v-model="origin"
                  label="Origin airport code"
                  :items="airportIDs"
                  required
                ></v-combobox>
                <v-combobox
                  v-model="destination"
                  label="Destination airport code"
                  :items="airportIDs"
                  required
                ></v-combobox>
                <v-text-field
                  v-model="departure_time"
                  label="Departure time (e.g. 2018-12-28 09:30:00)"
                  required
                ></v-text-field>
                <v-text-field
                  v-model="arrival_time"
                  label="Arrival time (e.g. 2018-12-28 15:10:00)"
                  required
                ></v-text-field>
                <v-combobox
                  v-model="airplane"
                  label="Airplane ID (e.g. 9)"
                  required
                  :items="airplaneIDs"
                ></v-combobox>
                <v-combobox
                  v-model="airline"
                  label="Airline"
                  :items="airlineIDs"
                  required
                ></v-combobox>

                <v-btn :disabled="!valid" @click="add">add flight</v-btn>
                <v-btn @click="clear">clear</v-btn>
              </v-form>

          <main role="main">
            <p class="subheading" v-html="this.formattedMessage"></p>
          </main>

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
  name: 'AddFlightForm',
  data() {
    return {
      origin: '',
      destination: '',
      departure_time: '2019-01-01 00:00:00',
      arrival_time: '2019-01-01 00:00:00',
      airplane: '',
      airline: '', 
      message: '',
      airportIDs: [],
      airlineIDs: [],
      airplaneIDs: [],
      showPasswordField: false,
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
  },
  created () {
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

      axios.get('/api/airplanes').then(res => {
          if (this.airplaneIDs.length == 0) {
            let rd = res.data;
            for (var i = 0; i < rd.length; i++) {
              this.airplaneIDs.push(rd[i].id.toString().concat(" - ").concat(rd[i].producer).concat(" ").concat(rd[i].model));
            }
          }
      });
  },
  methods: {
    add(){
      axios.post('/api/add_flight', {
            airplane: parseInt(this.airplane),
            airline: this.airline.substring(0,2),
            departure_time: this.departure_time,
            arrival_time: this.arrival_time,
            origin: this.origin.substring(0,3),
            destination: this.destination.substring(0,3),
        }).then((response) => {
            if (response.status == 200) {
              this.message = "New flight was successfully inserted";
            } else {
              this.message = "Error - inserting failed";
            }
          })
          .catch((error) => {
            this.message = "Error - inserting failed";
            console.log("ERR: " + error);
          });
    },
    clear(){
      this.$refs.form.reset();
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
