<template>
  <v-card class="layout column" light>

          <main role="main">
            <p class="subheading font-weight-regular"> Add new airplane</p>
          </main>

          <v-form ref="form" v-model="valid" lazy-validation>
                <v-text-field
                  v-model="producer"
                  :rules="cityRules"
                  label="Producer"
                  required
                ></v-text-field>
                <v-text-field
                  v-model="model"
                  label="Model"
                  required
                ></v-text-field>
                <v-text-field
                  v-model="fclassSeats"
                  :rules="intRules"
                  label="First class seats count"
                  required
                ></v-text-field>
                <v-text-field
                  v-model="bclassSeats"
                  :rules="intRules"
                  label="Business class seats count"
                  required
                ></v-text-field>
                <v-text-field
                  v-model="eclassSeats"
                  :rules="intRules"
                  label="Economy class seats count"
                  required
                ></v-text-field>
                <v-text-field
                  v-model="airline"
                  label="Airline"
                  required
                ></v-text-field>
                <v-btn :disabled="!valid" @click="add">add airplane</v-btn>
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
axios.defaults.headers.post['Content-Type'] = 'multipart/form-data';

export default {
  name: 'ChangePasswordForm',
  data() {
    return {
      producer: "",
      model: "",
      fclassSeats: "0",
      bclassSeats: "0",
      eclassSeats: "0",
      airline: "",
      message: "",
      rules: {
          required: value => !!value || 'Required.',
          min: v => (v && v.length >= 8) || 'Min 8 characters'
      },
      
      cityRules: [
        v => !!v || 'City name is required',
        v => (v && v.length <= 50) || 'City name must be shorter than 50 chars',
        v => /[A-Z]+/.test(v) || 'City must be valid'
      ],

      intRules: [
        v => !!v || 'Number of seats required',
        v => (v && v.length <= 4) || 'max 4 digit number expected',
        v => /[0-9]/.test(v) || 'Number must be valid'
      ],
      valid: true
    }
  },
  methods: {
    add(){
      axios.post('/api/add_airplane', {
            producer: this.producer,
            model: this.model,
            fclass_seats: this.fclassSeats,
            bclass_seats: this.bclassSeats,
            eclass_seats: this.eclassSeats,
            airline: this.airline
        }).then((response) => {
            if (response.status == 200) {
              this.message = "New airplane was successfully inserted";
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
