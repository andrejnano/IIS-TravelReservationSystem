<template>
  <v-content>
    <v-dialog
      v-model="loadingLogin"
      hide-overlay
      persistent
      width="400"
    >
      <v-card
        color="info"
        dark
      >
        <v-card-text>
           Trying to log in...
          <v-progress-linear
            indeterminate
            color="white"
            class="mb-0"
          ></v-progress-linear>
        </v-card-text>
      </v-card>
    </v-dialog>
    <v-dialog
      v-model="loadingSuccess"
      hide-overlay
      persistent
      width="400"
    >
      <v-card
        color="success"
        dark
      >
        <v-card-text>
           Logged in!
        </v-card-text>
      </v-card>
    </v-dialog>
    <v-dialog
      v-if="loadingFail"
      v-model="loadingFail"
      hide-overlay
      persistent
      width="400"
    >
      <v-card
        color="error"
        dark
      >
        <v-card-text>
           Log in failed!
        </v-card-text>
      </v-card>
    </v-dialog>
    <v-container fluid>
      <v-layout row justify-center>
        <v-flex xs10 sm8 md8 lg6 pa-2 ma-2>
          <v-card class="elevation-2">
            <v-card-title class="headline">Log in!</v-card-title>
            <v-card-text>
              <v-form ref="form" v-model="valid" lazy-validation>
                <v-text-field
                  v-model="email"
                  :rules="emailRules"
                  label="E-mail"
                  required
                ></v-text-field>
                <v-text-field
                  v-model="password"
                  :append-icon="showPasswordField ? 'visibility_off' : 'visibility'"
                  :rules="[rules.required, rules.min]"
                  :type="showPasswordField ? 'text' : 'password'"
                  name="password-input"
                  label="Enter your password"
                  hint="At least 8 characters"
                  counter
                  @click:append="showPasswordField = !showPasswordField"
                  required
                ></v-text-field>
                <v-btn
                  :disabled="!valid"
                  @click="submit"
                >
                  submit
                </v-btn>
                <v-btn @click="clear">clear</v-btn>
              </v-form>
            </v-card-text>
          </v-card>
        </v-flex>
      </v-layout>
    </v-container>
  </v-content>
</template>

<script>

import axios from 'axios'
axios.defaults.headers.post['Content-Type'] = 'multipart/form-data';

export default {
    data: () => ({
      loadingLogin: false,
      loadingSuccess: false,
      loadingFail: false,
      showPasswordField: false,
      password: '',
      rules: {
        required: value => !!value || 'Required.',
        min: v => v.length >= 8 || 'Min 8 characters',
        emailMatch: () => ('The email and password you entered don\'t match')
      },
      valid: true,
      email: '',
      emailRules: [
        v => !!v || 'E-mail is required',
        v => /.+@.+/.test(v) || 'E-mail must be valid'
      ],
    }),
    methods: {
      submit () {
        if (this.$refs.form.validate()) {
          this.loadingLogin = true;
          // Native form submission is not yet supported
          axios.post('/api/login', {
            email: this.email,
            password: this.password,
          })
          .then((response) => {

            if (response.status == 200) {
              console.log("LOGIN OK! : 200");
              this.$router.go({
                path: '/',
                force: true,
              });
              this.loadingLogin = false;
              this.loadingSuccess = true;
              setTimeout(function() {
                this.loadingSuccess = false;
              }, 2000);
            } else {
               this.loadingLogin = false;
               this.loadingFail = true;
              console.log("LOGIN FAILED! : " + response.status);
              setTimeout(function() {
                this.loadingFail = false;
              }, 2000);
            }
          }).catch((error) => {
              this.loadingLogin = false;
              this.loadingFail = true;
              setTimeout(function() {
                this.loadingFail = false;
              }, 2000);
              console.log("LOGIN FAILED! : " + error);
          });
          this.loadingFail = false;
        }
      },
      clear () {
        this.$refs.form.reset()
      }
    }
  }
</script>

<style>

</style>
