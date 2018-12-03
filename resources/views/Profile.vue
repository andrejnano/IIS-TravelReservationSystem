
<template>
  <v-content>
    <loading :active.sync="isLoading" :can-cancel="true" :on-cancel="loadingCancel" :is-full-page="fullPage"></loading>
    <v-container fluid>
      <reservations-component v-if="1"/>
      <v-layout ma-2 row>
        <v-flex ma-2 xs10 sm8 md6 lg6>
          <v-card role="main">
            <v-alert v-if="message.length > 0" type="info">
              {{this.message}}
            </v-alert>
            <v-card-title class="display-2 font-weight-bold mb-3">User information</v-card-title>
            <v-card-text class="subheading font-weight-regular"> First name:   <strong>{{this.user.first_name}}</strong></v-card-text>
            <v-card-text  class="subheading font-weight-regular"> Last name:   <strong>{{this.user.last_name}}</strong></v-card-text>
            <v-card-text class="subheading font-weight-regular"> E-mail:   <strong>{{this.user.email}}</strong></v-card-text>
          </v-card>
          <v-card>
            <v-card-text class="text-xs-center">
              <v-btn color="info" @click="updateInformation" large>
                Update information
                <span slot="submitLoader" class="custom-loader">
                  <v-icon light>cached</v-icon>
                </span>
              </v-btn>
            </v-card-text>
            <v-card-text class="text-xs-center">
              <v-btn color="info" @click="newPassword" large>
                Change password
                <span slot="submitLoader" class="custom-loader">
                  <v-icon light>cached</v-icon>
                </span>
              </v-btn>
            </v-card-text>
          </v-card>
        </v-flex>

        <v-flex ma-2 xs10 sm8 md6 lg6 v-if="passwordFormVisible">
          <v-card pa-2 role="main">
            <v-card-title class="subheading font-weight-regular"> Change password for user {{this.user.first_name}} {{this.user.last_name}}</v-card-title>
            <v-card-text>
              <v-form ref="form" v-model="valid" lazy-validation>
                  <v-text-field
                    v-model="password"
                    :append-icon="showPasswordField ? 'visibility_off' : 'visibility'"
                    :rules="[rules.required, rules.min]"
                    :type="showPasswordField ? 'text' : 'password'"
                    name="password-input"
                    label="Enter your new password"
                    hint="At least 8 characters"
                    counter
                    @click:append="showPasswordField = !showPasswordField"
                    required
                    color="secondary"
                  ></v-text-field>
                  <v-btn :disabled="!valid" @click="savePassword">save</v-btn>
                  <v-btn @click="cancelPassword">cancel</v-btn>
                </v-form>
            </v-card-text>
            <v-card-text class="text-xs-center">
            </v-card-text>
          </v-card>
        </v-flex>

        <v-flex ma-2 xs10 sm8 md6 lg6  v-if="informationFormVisible">
          <v-card pa-2 role="main">
            <v-card-title class="subheading font-weight-regular"> Change user information</v-card-title>

            <v-card-text>
              <v-form ref="form" v-model="valid" lazy-validation>
                <v-text-field
                  v-model="firstName"
                  :rules="nameRules"
                  label="First name"
                  required
                  color="secondary"
                ></v-text-field>
                <v-text-field
                  v-model="lastName"
                  :rules="nameRules"
                  label="Last name"
                  required
                  color="secondary"
                ></v-text-field>
                <v-text-field
                  v-model="email"
                  :rules="emailRules"
                  label="E-mail"
                  required
                  color="secondary"
                ></v-text-field>
                <v-btn :disabled="!valid" @click="saveInformation">save</v-btn>
                <v-btn @click="cancelInformation">cancel</v-btn>
              </v-form>
            </v-card-text>
          </v-card>

          <template v-if="sortToggle == 0">
          </template>

          <v-card-text class="text-xs-center">
          </v-card-text>
        </v-flex>

      </v-layout>
    </v-container>
  </v-content>
</template>

<script>

  import Loading from 'vue-loading-overlay';
  import 'vue-loading-overlay/dist/vue-loading.css';
  import {
    library
  } from '@fortawesome/fontawesome-svg-core'
  import {
    faSpinner
  } from '@fortawesome/free-solid-svg-icons'
  import {
    FontAwesomeIcon
  } from '@fortawesome/vue-fontawesome'
  import {
    dom
  } from '@fortawesome/fontawesome-svg-core'

  import ReservationComponent from '../components/Reservation.vue';
  import axios from 'axios'

  library.add(faSpinner)
  dom.watch() // This will kick of the initial replacement of i to svg tags and configure a MutationObserver

  export default {
    name: 'ProfileView',
    data() {
      return {
        isLoading: false,
        fullPage: true,
        //results: [],
        message: "",
        passwordFormVisible: false,
        informationFormVisible: false,
        showPasswordField: false,
        password: '',
        rules: {
          required: value => !!value || 'Required.',
          min: v => v.length >= 8 || 'Min 8 characters'
        },
        emailRules: [
          v => !!v || 'E-mail is required',
          v => /.+@.+/.test(v) || 'E-mail must be valid'
        ],
        nameRules: [
          v => !!v || 'Name is required',
          v => (v && v.length <= 10) || 'Name must be less than 10 characters'
        ],
        valid: true,
        user: [],
        firstName: "",
        lastName: "",
        email: ""
      }
    },
    created () {
      axios.get('/api/session').then(res => {
        this.user = res.data;
        this.firstName = this.user.first_name;
        this.lastName = this.user.last_name;
        this.email = this.user.email;
      });
    },
    methods: {
      loadingCancel() {
        console.log('User cancelled the loader.');
      },
      newPassword() {
        if(this.informationFormVisible == true){
          this.cancelInformation();
        }
        this.message = "";
        this.passwordFormVisible = true;
      },
      savePassword() {
        axios.post('/api/new_password', {
            new_password: this.password,
        }).then((response) => {
            if (response.status == 200) {
              this.message = "New password was saved!";
            } else {
              this.message = "Error - password was not set";
            }
          })
          .catch((error) => {
            this.message = "Error - password was not set";
            console.log("ERR: " + error);
          });
        this.passwordFormVisible = false;
        this.password = "";
      },
      cancelPassword () {
        this.passwordFormVisible = false;
        this.password = "";
      },
      updateInformation(){
        if(this.passwordFormVisible == true){
          this.cancelPassword();
        }
        this.message = "";
        this.informationFormVisible = true;
      },
      saveInformation(){
        axios.post('/api/update_information', {
            first_name: this.firstName,
            last_name: this.lastName,
            email: this.email
        }).then((response) => {
            if (response.status == 200) {
              this.message = "New information was saved!";
            } else {
              this.message = "Error - new information was not saved";
            }
          })
          .catch((error) => {
            this.message = "Error - new information was not saved";
            console.log("ERR: " + error);
          });
        this.informationFormVisible = false;
        this.user.first_name = this.firstName;
        this.user.last_name = this.lastName;
        this.user.email = this.email;
      },
      cancelInformation(){
        this.informationFormVisible = false;
        this.firstName = this.user.first_name;
        this.lastName = this.user.last_name;
        this.email = this.user.email;
      }
    },
    components: {
      'font-awesome-icon': FontAwesomeIcon,
      'reservations-component': ReservationComponent,
      Loading
    }
  }

</script>

<style lang="scss">
  // global stylesheet
  // @import '../design/style';

  #loading {
    position: fixed;
    opacity: 0.7;
    z-index: 1000;
    background: #000;
    height: 100%;
    width: 100%;
    display: none;
  }

  #loading.on {
    display: block;
  }

</style>
