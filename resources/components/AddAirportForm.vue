<template>
  <v-card class="layout column" light>

      <!-- TOOLBAR -->
      <v-toolbar card prominent>
        <v-toolbar-title><v-icon>mdi-airplane-landing</v-icon>&nbsp;&nbsp;Add new airport</v-toolbar-title>
      </v-toolbar>

          <v-form ref="form" v-model="valid" lazy-validation>
                <v-text-field
                  v-model="airportCode"
                  :rules="airportCodeRules"
                  label="Airport code (e.g. 'PRG')"
                  required
                ></v-text-field>
                <v-text-field
                  v-model="city"
                  :rules="cityRules"
                  label="City (e.g. 'Prague')"
                  required
                ></v-text-field>
                <v-text-field
                  v-model="country"
                  :rules="cityRules"
                  label="Country (e.g. 'Czech Republic')"
                  required
                ></v-text-field>
                <v-btn :disabled="!valid" @click="add">add airport</v-btn>
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
  name: 'ChangePasswordForm',
  data() {
    return {
      airportCode: "",
      city: "",
      country: "",
      message: "",
      airportIDs: [],
      rules: {
          required: value => !!value || 'Required.',
          min: v => (v && v.length >= 8) || 'Min 8 characters'
      },
      
      cityRules: [
        v => !!v || 'Name is required',
        v => (v && v.length <= 50) || 'Name must be shorter than 50 chars',
        v => /[A-Z]+/.test(v) || 'Name must be valid'
      ],
      airportCodeRules: [
        v => !!v || 'Airport code is required',
        v => (v && v.length == 3) || 'Airport code must be 3 characters',
        v => /[A-Z]{3}/.test(v) || 'Airport code must be valid',
        v => !this.airportIDs.includes(v) || 'Already taken',
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
  },
  created () {
      axios.get('/api/airports').then(res => {
          // this.airports = res.data;
          if (this.airportIDs.length == 0) {
            let rd = res.data;
            for (var i = 0; i < rd.length; i++) {
              this.airportIDs.push(rd[i].airport_code);
            }
          }
      });
  },
  methods: {
    add(){
      this.airportIDs.push(this.airportCode);
      axios.post('/api/add_airport', {
            airport_code: this.airportCode,
            city: this.city,
            country: this.country
        }).then((response) => {
            if (response.status == 200) {
              this.message = "New airport was successfully inserted";
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
