<template>
  <v-card class="layout column" light>

          <main role="main">
            <p class="subheading font-weight-regular"> Add new airline</p>
          </main>

          <v-form ref="form" v-model="valid" lazy-validation>
                <v-text-field
                  v-model="airline"
                  :rules="airlineRules"
                  label="Airline ID"
                  required
                ></v-text-field>
                <v-text-field
                  v-model="fullName"
                  :rules="nameRules"
                  label="Full name"
                  required
                ></v-text-field>
                <v-text-field
                  v-model="nationality"
                  :rules="nameRules"
                  label="Headquarter country"
                  required
                ></v-text-field>
                <v-text-field
                  v-model="hub"
                  :rules="airportRules"
                  label="Hub airport"
                  required
                ></v-text-field>
                <v-btn :disabled="!valid" @click="add">add airport</v-btn>
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
  name: 'ChangePasswordForm',
  data() {
    return {
      airline: "",
      fullName: "",
      nationality: "",
      nationality: "",
      message: "",
      hub: "",
      rules: {
          required: value => !!value || 'Required.',
          min: v => (v && v.length >= 8) || 'Min 8 characters'
      },
      
      nameRules: [
        v => !!v || 'Name is required',
        v => (v && v.length <= 50) || 'Name must be shorter than 50 chars',
        v => /[A-Z]+/.test(v) || 'Name must be valid'
      ],
      airlineRules: [
        v => !!v || 'Airline code is required',
        v => (v && v.length == 2) || 'Airline code must be 2 characters',
        v => /[A-Z]{2}/.test(v) || 'Airline code must be valid'
      ],
      airportRules: [
        v => !!v || 'Airport code is required',
        v => (v && v.length == 3) || 'Airport code must be 3 characters',
        v => /[A-Z]{3}/.test(v) || 'Airport code must be valid'
      ],
      valid: true
    }
  },
  methods: {
    add(){
      axios.post('/api/add_airline', {
          airline: this.airline,
          full_name: this.fullName,
          nationality: this.nationality,
          hub: this.hub
        }).then((response) => {
            if (response.status == 200) {
              this.message = "New airline was successfully inserted";
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
