<template>
  <v-content>
    <loading :active.sync="isLoading" :can-cancel="true" :on-cancel="loadingCancel" :is-full-page="fullPage"></loading>
    <v-container fluid>
      <v-layout ma-2 row align-start>
        <v-flex ma-2 xs12 sm5 md4 lg4>
          <flight-search-form v-bind="formValuesToPass" />
        </v-flex>
        <v-flex ma-2 xs12 sm6 md7 lg4>
          <main role="main">
            <h1 class="display-2 font-weight-bold mb-3">Frontpage Headline</h1>
            <p class="subheading font-weight-regular"> Lorem ipsum dolor sit, amet consectetur adipisicing elit.
              Voluptatem animi esse at, labore exercitationem non tempore, eos iste ut, quisquam perspiciatis rerum?
              Sit sequi commodi culpa autem eum ad omnis.</p>
          </main>
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

  library.add(faSpinner)
  dom.watch() // This will kick of the initial replacement of i to svg tags and configure a MutationObserver

  import FlightSearchForm from '../components/FlightSearchForm.vue';

  // custom mutation of date class
  Date.prototype.addDays = function (days) {
    var date = new Date(this.valueOf());
    date.setDate(date.getDate() + days);
    return date;
  }


  // temp debug wait, remove later
  function wait(ms) {
    var start = new Date().getTime();
    var end = start;
    while (end < start + ms) {
      end = new Date().getTime();
    }
  }

  // default form values
  const initialFormValues = {
    origin: {
      airport_code: 'VIE',
      city: 'Vienna'
    },
    destination: {
      airport_code: 'JFK',
      city: 'New York'
    },
    departureDate: new Date().toISOString().substr(0,10),
    arrivalDate: new Date().addDays(7).toISOString().substr(0,10),
    priceMin: 50,
    priceMax: 3000,
    setClass: 0
  };

  export default {
    name: 'SearchView',
    data() {
      return {
        isLoading: false,
        fullPage: true,
        results: [],
        formValuesToPass: initialFormValues
      }
    },
    methods: {
      loadingCancel() {
        console.log('User cancelled the loader.');
      }
    },
    components: {
      'flight-search-form': FlightSearchForm,
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
