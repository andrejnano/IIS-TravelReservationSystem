// Setup Vue.js
window.Vue = require('vue');

Vue.config.devtools = true;
Vue.config.performance = true;

// Setup Vue Router
import VueRouter from 'vue-router';
import BootstrapVue from 'bootstrap-vue'

Vue.use(VueRouter);
Vue.use(BootstrapVue);

import App from './App.vue';

import SearchView from './views/SearchView.vue';
import ResultsView from './views/ResultsView.vue';

import Help from './views/Help.vue';
import FAQ from './views/FAQ.vue';
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
      component: SearchView
    },
    {
      path: '/help',
      name: 'help',
      component: Help
    },
    {
      path: '/faq',
      name: 'faq',
      component: FAQ
    },
    {
      path: '/contact',
      name: 'contact',
      component: Contact
    },
    {
      path: '/searched',
      name: 'results',
      component: ResultsView,
    }
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
