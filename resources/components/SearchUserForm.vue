<template>
  <v-card class="layout column" light>

      <!-- TOOLBAR -->
      <v-toolbar card prominent>
        <v-toolbar-title><v-icon>mdi-account</v-icon>&nbsp;&nbsp;Users table</v-toolbar-title>
      </v-toolbar>

        <!-- SEARCH FORM -->
        <v-flex ma-2 xs11 sm8 md6 lg4 v-if="this.actualUser == 0">
          <v-btn-toggle v-model="toggleSearch" mandatory>
            <v-btn flat>First name</v-btn>
            <v-btn flat>Last name</v-btn>
            <v-btn flat>E-mail</v-btn>
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
        <v-flex ma-2 xs11 sm8 md6 lg4 v-if="this.actualUser != 0">
          <v-form ref="form" v-model="valid" lazy-validation>
                <v-checkbox
                  v-model="isAdmin"
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
                <v-btn :disabled="!valid" @click="save">save</v-btn>
                <v-btn @click="cancel">cancel</v-btn>
                <v-btn color="red" @click="deleteUser">
                  <v-icon light>mdi-delete</v-icon>delete user
                </v-btn>
          </v-form>
        </v-flex>

          <main role="main">
            <p class="subheading" v-html="this.formattedMessage"></p>
          </main>
          <main role="main">
            <p class="subheading" v-html="this.formattedSearchMessage"></p>
          </main>

            <!-- USER LIST -->
            <v-list-tile v-for="user in users" :key="user.id" avatar ripple>
              <v-list-tile-content>
                <v-list-tile-title> {{ user.id }}  | {{ user.first_name }} {{ user.last_name }} {{ user.is_admin ? "[admin]" : ""}}</v-list-tile-title>
                <v-list-tile-sub-title > {{ user.email }} </v-list-tile-sub-title>
              </v-list-tile-content>
              <v-spacer></v-spacer>
              <v-btn dark color="green"
              @click="editUser(user)"
              large>EDIT</v-btn>
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
  name: 'ChangePasswordForm',
  data() {
    return {
      firstName: "",
      lastName: "",
      email: "", 
      isAdmin: false,
      message: "",
      searchMessage: "",
      actualUser: 0,
      fullName: "",
      users: [],
      toggleSearch: 0,
      searchString: "",
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
    formattedSearchMessage() {
      return '<font color="grey">' + this.searchMessage + '</font>';
    }
  },
  created () {
    axios.get('/api/users', {
        }).then((response) => {
            if (response.status == 200) {
              this.users = response.data;
              this.searchMessage = "All users";
            } else {
              this.message = "Error - not able to get users";
            }
          })
          .catch((error) => {
            this.message = "Error - not able to get users";
            console.log("ERR: " + error);
          });
  },
  methods: {
    editUser(editedUser) {
      this.actualUser = editedUser.id;
      this.firstName = editedUser.first_name;
      this.lastName = editedUser.last_name;
      this.email = editedUser.email;
      this.isAdmin = editedUser.is_admin == 1 ? true : false;
    },
    search() {
      axios.get('/api/users', {
        }).then((response) => {
            if (response.status == 200) {
                this.users = [];
                if(this.toggleSearch == 0) {
                  response.data.forEach(user => {
                    if(user.first_name.search(this.searchString) > -1){
                      this.users.push(user);
                    }
                  });
                  this.searchMessage = "Users containing '" + this.searchString + "' in first name";
                } else if (this.toggleSearch == 1) {
                  response.data.forEach(user => {
                    if(user.last_name.search(this.searchString) > -1){
                      this.users.push(user);
                    }
                  });
                  this.searchMessage = "Users containing '" + this.searchString + "' in last name";
                } else {
                  response.data.forEach(user => {
                    if(user.email.search(this.searchString) > -1){
                      this.users.push(user);
                    }
                  });
                  this.searchMessage = "Users containing '" + this.searchString + "' in email";
                }
                if(this.searchString == ""){
                  this.searchMessage = "All users";
                }
            } else {
              this.message = "Error - not able to get users";
            }
          })
          .catch((error) => {
            this.message = "Error - not able to get users";
            console.log("ERR: " + error);
          });
    },
    save() {
      this.fullName = this.firstName + " " + this.lastName;
      console.log(this.isAdmin === true ? 1 : 0);
      console.log(this.isAdmin);
      axios.post('/api/update_user', {
            id: this.actualUser,
            first_name: this.firstName,
            last_name: this.lastName,
            email: this.email,
            is_admin: this.isAdmin === true ? 1 : 0
        }).then((response) => {
            if (response.status == 200) {
              this.message = "User " + this.fullName + " was successfully saved";
              axios.get('/api/users', {
                }).then((response) => {
                    if (response.status == 200) {
                      this.users = response.data;
                    } else {
                      this.message = "Error - not able to get users";
                    }
                  })
                  .catch((error) => {
                    this.message = "Error - not able to get users";
                    console.log("ERR: " + error);
                  });  
            } else {
              this.message = "Error - information was not saved";
            }
          })
          .catch((error) => {
            this.message = "Error - information was not saved";
            console.log("ERR: " + error);
          });    
    },
    cancel() {
      this.$refs.form.reset();
      this.actualUser = 0;
    },
    deleteUser() {
      this.fullName = this.firstName + " " + this.lastName;
      axios.post('/api/delete_user', {
            id: this.actualUser,
        }).then((response) => {
            if (response.status == 200) {
              this.message = "User " + this.fullName + " was successfully deleted";
            } else {
              this.message = "Error - user was not deleted";
            }
          })
          .catch((error) => {
            this.message = "Error - user was not deleted";
            console.log("ERR: " + error);
          });
      this.$refs.form.reset();
      this.actualUser = 0;
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
