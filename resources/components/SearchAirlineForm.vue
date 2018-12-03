<template>
  <v-card class="layout column" light>

        <!-- SEARCH FORM -->
        <v-flex ma-2 xs11 sm8 md6 lg4 v-if="this.actualAirline == ''">
          <v-btn-toggle v-model="toggleSearch" mandatory>
            <v-btn flat>Airline code</v-btn>
            <v-btn flat>Full name</v-btn>
            <v-btn flat>Nationality</v-btn>
            <v-btn flat>Hub</v-btn>
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
        <v-flex ma-2 xs11 sm8 md6 lg4 v-if="this.actualAirline != ''">
          <main role="main">
            <p class="subheading font-weight-regular"> {{this.actualAirline}}</p>
          </main>
          <v-form ref="form" v-model="valid" lazy-validation>
                <v-text-field
                  v-model="fullName"
                  label="Full name"
                  required
                ></v-text-field>
                <v-text-field
                  v-model="nationality"
                  label="Nationality"
                  required
                ></v-text-field>
                <v-text-field
                  v-model="hub"
                  label="Hub"
                  required
                ></v-text-field>
                <v-text-field
                  v-model="idLogo"
                  label="Logo file name"
                  required
                ></v-text-field>
                <v-btn :disabled="!valid" @click="save">save</v-btn>
                <v-btn @click="cancel">cancel</v-btn>
                <v-btn color="red" @click="deleteAirline">
                  <v-icon light>mdi-delete</v-icon>delete airline
                </v-btn>
          </v-form>
        </v-flex>

          <main role="main">
            <p class="subheading font-weight-regular"> {{this.message}}</p>
          </main>

          <main role="main">
            <p class="subheading font-weight-regular"> {{this.searchMessage}}</p>
          </main>

            <!-- AIRLINE LIST -->
            <v-list-tile v-for="airline in airlines" :key="airline.airline" avatar ripple>
              <v-list-tile-content>
                <v-list-tile-title> {{ airline.airline }}  | {{ airline.full_name }} | hub: {{ airline.hub }} </v-list-tile-title>
                <v-list-tile-sub-title > {{ airline.nationality }} | logo: {{ airline.id_logo }} </v-list-tile-sub-title>
              </v-list-tile-content>
              <v-spacer></v-spacer>
              <v-btn dark color="green" @click="editAirline(airline)" large>
                EDIT<v-icon light>mdi-pencil-outline</v-icon>
              </v-btn>
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
  name: 'SearchAirlineForm',
  data() {
    return {
      actualAirline: "",
      fullName: "",
      nationality: "",
      hub: "",
      idLogo: "",
      message: "",
      searchMessage: "",
      airlines: [],
      toggleSearch: 0,
      searchString: "",
      deletedName: "",
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
    axios.get('/api/airlines', {
        }).then((response) => {
            if (response.status == 200) {
              this.airlines = response.data;
              this.searchMessage = "All airlines";
            } else {
              this.message = "Error - not able to get airlines";
            }
          })
          .catch((error) => {
            this.message = "Error - not able to get airlines";
            console.log("ERR: " + error);
          });
  },
  methods: {
    editAirline(editedAirline) {
      this.actualAirline = editedAirline.airline;
      this.fullName = editedAirline.full_name;
      this.nationality = editedAirline.nationality;
      this.hub = editedAirline.hub;
      this.idLogo = editedAirline.id_logo;
    },
    search() {
      axios.get('/api/airlines', {
        }).then((response) => {
            if (response.status == 200) {
                this.airlines = [];
                if(this.toggleSearch == 0) {
                  response.data.forEach(airline => {
                    if(airline.airline.search(this.searchString) > -1){
                      this.airlines.push(airline);
                    }
                  });
                  this.searchMessage = "Airlines containing '" + this.searchString + "' in airline code";
                } else if (this.toggleSearch == 1) {
                  response.data.forEach(airline => {
                    if(airline.full_name.search(this.searchString) > -1){
                      this.airlines.push(airline);
                    }
                  });
                  this.searchMessage = "Airlines containing '" + this.searchString + "' in full name";
                } else if (this.toggleSearch == 2) {
                  response.data.forEach(airline => {
                    if(airline.nationality.search(this.searchString) > -1){
                      this.airlines.push(airline);
                    }
                  });
                  this.searchMessage = "Airlines containing '" + this.searchString + "' in nationality";
                } else {
                  response.data.forEach(airline => {
                    if(airline.hub.search(this.searchString) > -1){
                      this.airlines.push(airline);
                    }
                  });
                  this.searchMessage = "Airlines containing '" + this.searchString + "' in hub";
                }
                if(searchString == ""){
                  this.searchMessage = "All airlines";
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
    save() {
      axios.post('/api/update_airline', {
            airline: this.actualAirline,
            full_name: this.fullName,
            nationality: this.nationality,
            hub: this.hub,
            id_logo: this.idLogo
        }).then((response) => {
            if (response.status == 200) {
              this.message = "Airline information was successfully saved!";
            } else {
              this.message = "Error - information was not saved";
            }
            this.search(); // actualize table
          })
          .catch((error) => {
            this.message = "Error - information was not saved";
            console.log("ERR: " + error);
          });
      /*axios.get('/api/airlines', {
        }).then((response) => {
            if (response.status == 200) {
              this.airlines = response.data;
            } else {
              this.message = "Error - not able to get airlines";
            }
          })
          .catch((error) => {
            this.message = "Error - not able to get airlines";
            console.log("ERR: " + error);
          });*/      
    },
    cancel() {
      this.$refs.form.reset();
      this.actualAirline = "";
    },
    deleteAirline() {
      this.deletedName = this.fullName;
      axios.post('/api/delete_airline', {
            airline: this.actualAirline,
        }).then((response) => {
            if (response.status == 200) {
              this.message = "Airline " + this.deletedName + " was successfully deleted";
            } else {
              this.message = "Error - airline was not deleted";
            }
          })
          .catch((error) => {
            this.message = "Error - airline was not deleted";
            console.log("ERR: " + error);
          });
      this.$refs.form.reset();
      this.actualAirline = ""; // hide edit form
      this.search(); // actualize table
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
