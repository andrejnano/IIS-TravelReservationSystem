<template>
  <v-content>
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
            } else {
              console.log("LOGIN FAILED! : " + response.status);
            }
          })
          .catch((error) => {
            console.log("ERR: " + error);
          });
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
