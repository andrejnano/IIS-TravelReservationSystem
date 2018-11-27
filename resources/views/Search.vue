<template>
  <div id="search-view">
    <loading :active.sync="isLoading" :can-cancel="true" :on-cancel="loadingCancel" :is-full-page="fullPage"></loading>

    <b-container id="content" fluid>
      <b-row>

        <b-col cols="12" sm="12" md="6" lg="4">
          <aside class='side-bar'>
            <flight-search-form v-bind="formValuesToPass">
            </flight-search-form>
          </aside>
        </b-col>

        <b-col cols="12" sm="12" md="6" lg="8">
          <main role='main' class='main'>
            <h1>Frontpage Headline</h1>
            <p> Lorem ipsum dolor sit, amet consectetur adipisicing elit. Voluptatem animi esse at, labore exercitationem non tempore, eos iste ut, quisquam perspiciatis rerum? Sit sequi commodi culpa autem eum ad omnis.</p>
          </main>
        </b-col>

      </b-row>

    </b-container>

  </div>
</template>

<script>

import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';

import Loading from 'vue-loading-overlay';
import 'vue-loading-overlay/dist/vue-loading.css';
import { library } from '@fortawesome/fontawesome-svg-core'
import { faSpinner } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { dom } from '@fortawesome/fontawesome-svg-core'

library.add(faSpinner)
dom.watch() // This will kick of the initial replacement of i to svg tags and configure a MutationObserver

import FlightSearchForm from '../components/FlightSearchForm.vue';

// custom mutation of date class
Date.prototype.addDays = function(days) {
  var date = new Date(this.valueOf());
  date.setDate(date.getDate() + days);
  return date;
}

function FlightResult({ origin, destination, price}) {
  this.origin = origin;
  this.destination = destination;
  this.price = price;
}

// temp debug wait, remove later
function wait(ms) {
  var start = new Date().getTime();
  var end = start;
  while(end < start + ms) {
    end = new Date().getTime();
  }}


const initialFormValues = {
  isRoundTrip: true,
  isOneWay: false,
  origin: {code: 'VIE', full: 'Vienna'},
  destination: {code: '', full: ''},
  departureDate: new Date(),
  arrivalDate: new Date(),
  priceMin: 200,
  priceMax: 1200
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
  @import '../design/style';

  aside.side-bar {

  }

  main.main {

  }

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
