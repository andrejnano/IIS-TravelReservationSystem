<template>
  <div id="results-view">
    <loading :active.sync="isLoading" :can-cancel="true" :on-cancel="loadingCancel" :is-full-page="fullPage"></loading>

    <b-container id="content" fluid>
      <b-row>

        <b-col cols="12" sm="12" md="4" lg="4">
          <aside class='side-container'>
            <flight-search-form
              v-bind="formValuesToPass"
              @searchSubmited="search">
            </flight-search-form>
          </aside>
        </b-col>

        <b-col cols="12" sm="12" md="8" lg="8">
          <main role='main' class='main'>
            <flight-result-component
              v-for="result in results"
              v-bind="result"
              :key="result.price">
            </flight-result-component>
          </main>
        </b-col>

      </b-row>
    </b-container>
  </div>
</template>

<script>
import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';


// custom mutation of date class
Date.prototype.addDays = function(days) {
  var date = new Date(this.valueOf());
  date.setDate(date.getDate() + days);
  return date;
}

// function FlightResult({ airline: {airline, full_name, nationality, hub},
//                         airplane: {airline, model, producer},
//                         departure_time,
//                         destination: {airport, city, country},
//                         flight_number,
//                         flight_time,
//                         origin: {airport, city, country},
//                         price,
//                         seat_class,
//                         tickets
// }) {
//   this.origin = origin;
//   this.destination = destination;
//   this.price = price;
// }

import Loading from 'vue-loading-overlay';
import 'vue-loading-overlay/dist/vue-loading.css';
import { library } from '@fortawesome/fontawesome-svg-core'
import { faSpinner } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { dom } from '@fortawesome/fontawesome-svg-core'
library.add(faSpinner)
dom.watch() // This will kick of the initial replacement of i to svg tags and configure a MutationObserver
import FlightSearchForm from '../components/FlightSearchForm.vue';
import FlightResultComponent from '../components/FlightResult.vue';

import axios from 'axios';

const initialFormValues = {
  isRoundTrip: true,
  isOneWay: false,
  origin: {code: 'VIE', full: 'Vienna'},
  destination: {code: '', full: ''},
  departureDate: new Date(),
  arrivalDate: new Date().addDays(7),
  priceMin: 200,
  priceMax: 1200
};

export default {
  name: 'ResultsView',
  data() {
    return {
      isLoading: false,
      fullPage: true,
      results: [],
      formValuesToPass: {
        isRoundTrip: JSON.parse(this.$route.query.isRoundTrip),
        isOneWay: JSON.parse(this.$route.query.isOneWay),
        origin: {code: this.$route.query.originCode, full: this.$route.query.originFull},
        destination: {code: this.$route.query.destinationCode, full: this.$route.query.destinationFull},
        departureDate: new Date(JSON.parse(this.$route.query.departureDate)),
        arrivalDate: new Date(JSON.parse(this.$route.query.arrivalDate)),
        priceMin: JSON.parse(this.$route.query.priceMin),
        priceMax: JSON.parse(this.$route.query.priceMax),
      },
    }
  },
  methods: {
    search(formValues) {
      // perform search query to the API
      this.isLoading = true;
      this.results = [];  // reset the results


      // TODO: prepare query string
      //localhost:8080/api/search?origin={origin.code}&destination={destination.code}
      //localhost:8080/api/search?origin=VIE&destination=CDG

      // prepare the query from form data
      let query = `/api/search?origin=${formValues.origin.code}&destination=${formValues.destination.code}`;

      // perform the query
      axios.get(query).then((response) => {

        // check if the request went OK
        if (response.status == 200) {
          console.log("QUERY OK! : 200");
        } else {
          return; // TODO: not found
        }

        // extract only the data part
        let responseResults = response.data;

        responseResults.forEach(flightResult => {

          // TODO: check if result returned correctly
          console.log(flightResult.there);

          // add result to the view model
          this.results.push( { result: flightResult.there } );

        });
        this.isLoading = false;

      });
    },
    loadingCancel() {
      console.log('User cancelled the loader.');
    }
  },
  created() {
    this.search(this.formValuesToPass);
  },
  components: {
    'flight-result-component': FlightResultComponent,
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

  .flight-results__wrap {
    height: 50%;
    width: 100%;
    background: rgba(0,0,0,0.05);
    display: flex;
    flex-direction: column;
    align-items: left;

    .flight-results__headline {
      margin: 1em 2em;
    }
  }
</style>
