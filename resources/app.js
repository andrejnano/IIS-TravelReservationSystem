/**
 * Flight Reservation System
 */


import '@babel/polyfill'

// Setup Vue.js
window.Vue = require('vue');

Vue.config.devtools = true;
Vue.config.performance = true;

// Setup Vue Router
import VueRouter from 'vue-router';
import VueResource from 'vue-resource';
import Vuetify from 'vuetify';
import 'vuetify/dist/vuetify.min.css';
import '@mdi/font/css/materialdesignicons.css';
import 'material-design-icons-iconfont/dist/material-design-icons.css';

import colors from 'vuetify/es5/util/colors';
import VueHtml2Canvas from 'vue-html2canvas';

Vue.use(VueHtml2Canvas);

var theme_1 = {
  primary: '#3A55FF',
  secondary: '#E3E834',
  accent: '#100D23',
};

var theme_2 = {
  primary: '#100D23',
  secondary: '#00E676',
  accent: '#FF4081',
  success: '#00E676',
  error: '#F44336'
};

Vue.use(VueRouter);
Vue.use(Vuetify, {
  iconfont: 'mdi',
  theme: theme_2,
});

Vue.use(VueResource);


import App from './App.vue';

import Search from './views/Search.vue';
import Results from './views/Results.vue';
import Login from './views/Login.vue';
import Register from './views/Register.vue';
import Profile from './views/Profile.vue';
import Flight from './views/Flight.vue';
import About from './views/About.vue';
import Contact from './views/Contact.vue';
import Admin from './views/Admin.vue';

// create new Router, handling SPA routes
const router = new VueRouter({
  mode: 'history',
  scrollBehavior(to, from) {
    return {
      x: 0,
      y: 0
    }
  },
  routes: [{
      path: '/',
      name: 'landing',
      component: Search
    },
    {
      path: '/about',
      name: 'about',
      component: About
    },
    {
      path: '/contact',
      name: 'contact',
      component: Contact
    },
    {
      path: '/searched',
      name: 'results',
      component: Results,
    },
    {
      path: '/login',
      name: 'login',
      component: Login,
    },
    {
      path: '/register',
      name: 'register',
      component: Register,
    },
    {
      path: '/profile',
      name: 'profile',
      component: Profile,
    },
    {
      path: '/flight',
      name: 'flight',
      component: Flight,
    },
    {
      path: '/admin',
      name: 'admin',
      component: Admin,
    },
  ],
})

/**
 * We will create a fresh Vue application instance and attach it to
 * the page. Then, you may begin adding components to this application
 * or customize the JavaScript scaffolding to fit your unique needs.
 */

const app = new Vue({
  el: '#app',
  components: {
    App
  },
  router,
  render: h => h(App)
});
