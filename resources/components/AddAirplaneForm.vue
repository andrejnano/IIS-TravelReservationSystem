<template>
  <v-card class="layout column" light>

      <!-- TOOLBAR -->
      <v-toolbar card prominent>
        <v-toolbar-title><v-icon>mdi-airplane</v-icon>&nbsp;&nbsp;Add new airplane</v-toolbar-title>
      </v-toolbar>

          <v-form ref="form" v-model="valid" lazy-validation>
                <v-text-field
                  v-model="producer"
                  :rules="nameRules"
                  label="Producer (e.g. Boeing)"
                  required
                ></v-text-field>
                <v-text-field
                  v-model="model"
                  label="Model (e.g. 777-300ER)"
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
                <v-combobox
                  v-model="airline"
                  label="Airline"
                  :items="airlineIDs"
                  required
                ></v-combobox>
                <v-btn :disabled="!valid" @click="add">add airplane</v-btn>
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
      airlineIDs: [],
      rules: {
          required: value => !!value || 'Required.',
          min: v => (v && v.length >= 8) || 'Min 8 characters'
      },
      
      nameRules: [
        v => !!v || 'Name name is required',
        v => (v && v.length <= 50) || 'Name name must be shorter than 50 chars',
        v => /[A-Z]+/.test(v) || 'Name must be valid'
      ],

      intRules: [
        v => !!v || 'Number of seats required',
        v => (v && v.length <= 4) || 'max 4 digit number expected',
        v => /[0-9]/.test(v) || 'Number must be valid'
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
      axios.get('/api/airlines').then(res => {
          // this.airports = res.data;
          if (this.airlineIDs.length == 0) {
            let rd = res.data;
            for (var i = 0; i < rd.length; i++) {
              this.airlineIDs.push(rd[i].airline.concat(" - ").concat(rd[i].full_name));
            }
          }
      });
  },
  methods: {
    add(){
      axios.post('/api/add_airplane', {
            producer: this.producer,
            model: this.model,
            fclass_seats: this.fclassSeats,
            bclass_seats: this.bclassSeats,
            eclass_seats: this.eclassSeats,
            airline: this.airline.substring(0,2),
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
