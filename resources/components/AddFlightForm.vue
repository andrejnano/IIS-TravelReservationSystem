<template>
  <v-card class="layout column" light>

          <main role="main">
            <p class="subheading font-weight-regular"> Add new flight</p>
          </main>

          <v-form ref="form" v-model="valid" lazy-validation>
                <v-text-field
                  v-model="origin"
                  label="Origin airport code (e.g. LHR)"
                  required
                ></v-text-field>
                <v-text-field
                  v-model="destination"
                  label="Destination airport code (e.g. JFK)"
                  required
                ></v-text-field>
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
                <v-text-field
                  v-model="airplane"
                  label="Airplane ID (e.g. 9)"
                  required
                ></v-text-field>
                <v-text-field
                  v-model="airline"
                  label="Airline (e.g. AY)"
                  required
                ></v-text-field>
                <v-btn :disabled="!valid" @click="add">add flight</v-btn>
                <v-btn @click="clear">clear</v-btn>
              </v-form>

          <main role="main">
            <p class="subheading font-weight-regular"> {{this.message}}</p>
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
      departure_time: '',
      arrival_time: '',
      airplane: '',
      airline: '', 
      message: '',
      showPasswordField: false,
      rules: {
          required: value => !!value || 'Required.',
          min: v => (v && v.length >= 8) || 'Min 8 characters'
      },
      emailRules: [
        v => !!v || 'E-mail is required',
        v => /.+@.+/.test(v) || 'E-mail must be valid'
      ],
      nameRules: [
        v => !!v || 'Name is required',
        v => (v && v.length <= 10) || 'Name must be less than 10 characters'
      ],
      valid: true
    }
  },
  methods: {
    add(){
      axios.post('/api/add_flight', {
            airplane: this.airplane,
            airline: this.airline,
            departure_time: this.departure_time,
            arrival_time: this.arrival_time,
            origin: this.origin,
            destination: this.destination
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
