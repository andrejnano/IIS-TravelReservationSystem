<template>
  <v-content>
    <loading :active.sync="isLoading" :can-cancel="true" :on-cancel="loadingCancel" :is-full-page="fullPage"></loading>
    <v-container fluid>
      <v-layout ma-2 row align-start>
        <v-flex ma-2 xs11 sm9 md7 lg5>
          <main role="main">
            <p class="subheading font-weight-regular"> {{this.message}}</p>
            <h1 class="display-2 font-weight-bold mb-3">User information</h1><br>
            <p class="subheading font-weight-regular"> First name:   <b>{{this.user.first_name}}</b></p>
            <p class="subheading font-weight-regular"> Last name:   <b>{{this.user.last_name}}</b></p>
            <p class="subheading font-weight-regular"> E-mail:   <b>{{this.user.email}}</b></p>
          </main>
          <v-card-text class="text-xs-center">
            <v-btn
              color="info"
              @click="newPassword"
              large
            >
              Change password
              <span slot="submitLoader" class="custom-loader">
                <v-icon light>cached</v-icon>
              </span>
            </v-btn>
          </v-card-text>
        </v-flex>

        <v-flex ma-2 xs11 sm8 md6 lg4 v-if="passwordFormVisible">
          <main role="main">
            <p class="subheading font-weight-regular"> Change password for user {{this.user.first_name}} {{this.user.last_name}}</p>
          </main>

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
                ></v-text-field>
                <v-btn :disabled="!valid" @click="savePassword">submit</v-btn>
                <v-btn @click="cancel">cancel</v-btn>
              </v-form>

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
        showPasswordField: false,
        password: '',
        rules: {
          required: value => !!value || 'Required.',
          min: v => v.length >= 8 || 'Min 8 characters'
        },
        valid: true,
        user: []
      }
    },
    created () {
      axios.get('/api/session').then(res => {
        this.user = res.data;
      });
    },
    methods: {
      loadingCancel() {
        console.log('User cancelled the loader.');
      },
      newPassword() {
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
      cancel () {
        this.passwordFormVisible = false;
        this.password = "";
      }
    },
    components: {
      'font-awesome-icon': FontAwesomeIcon,
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
