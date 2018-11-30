// Setup Vue.js
window.Vue = require('vue');

Vue.config.devtools = true;
Vue.config.performance = true;

// Setup Vue Router
import VueRouter from 'vue-router';
import VueResource from 'vue-resource';
import Vuetify from 'vuetify'
import 'vuetify/dist/vuetify.min.css'
import '@mdi/font/css/materialdesignicons.css'
import 'material-design-icons-iconfont/dist/material-design-icons.css'

Vue.use(VueRouter);
Vue.use(Vuetify, {
  iconfont: 'mdi'
});

Vue.use(VueResource);


import App from './App.vue';

import Search from './views/Search.vue';
import Results from './views/Results.vue';
import Login from './views/Login.vue';
import Register from './views/Register.vue';
// import Profile from './views/Profile.vue';
import Flight from './views/Flight.vue';
import About from './views/About.vue';
import Contact from './views/Contact.vue';

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
    // {
    //   path: '/profile',
    //   name: 'profile',
    //   component: Profile,
    // },
    {
      path: '/flight',
      name: 'flight',
      component: Flight,
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
