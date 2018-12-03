<template>
  <v-card class="layout column" light>

      <!-- TOOLBAR -->
      <v-toolbar card prominent>
        <v-toolbar-title><v-icon>mdi-account</v-icon>&nbsp;&nbsp;Add new user</v-toolbar-title>
      </v-toolbar>

          <v-form ref="form" v-model="valid" lazy-validation>
                <v-checkbox
                  v-model="admin"
                  true-value=true
                  false-value=false
                  label="Is admin"
                  required
                ></v-checkbox>
                <v-text-field
                  v-model="firstName"
                  :rules="nameRules"
                  label="First name"
                  required
                ></v-text-field>
                <v-text-field
                  v-model="lastName"
                  :rules="nameRules"
                  label="Last name"
                  required
                ></v-text-field>
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
                  label="Password"
                  hint="At least 8 characters"
                  counter
                  @click:append="showPasswordField = !showPasswordField"
                  required
                ></v-text-field>
                <v-btn :disabled="!valid" @click="add">add user</v-btn>
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
      firstName: "",
      lastName: "",
      email: "",
      password: "", 
      message: "",
      admin: false,
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
  computed: {
    formattedMessage() {
      if(this.message.substring(0,5) == "Error"){
        return '<font color="red">' + this.message + '</font>';
      }
      return '<font color="green">' + this.message + '</font>';
    },
  },
  methods: {
    add(){
      // console.log(this.admin);
      // console.log(this.admin === "true" ? 1 : 0);
      console.log(this.firstName);
      console.log(this.lastName);
      axios.post('/api/add_user', {
            first_name: this.firstName,
            last_name: this.lastName,
            email: this.email,
            password: this.password,
            is_admin: this.admin === "true" ? 1 : 0
        }).then((response) => {
            if (response.status == 200) {
              this.message = "New user was successfully inserted";
            } else {
              this.message = "Error - inserting failed";
            }
          })
          .catch((error) => {
            this.message = "Error - inserting failed";
            if(error.status == 409){
              this.message = "Error - user with this email already exists!";
            }
            console.log("ERR: " + error);
          });
      this.$refs.form.reset();
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
