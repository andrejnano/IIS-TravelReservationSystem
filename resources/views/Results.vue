<template>
  <v-content>
    <loading :active.sync="isLoading" :can-cancel="true" :on-cancel="loadingCancel" :is-full-page="fullPage"></loading>
    <v-container fluid>
      <v-layout ma-2 row align-start fill-height>
        <v-flex ma-2 xs12 sm5 md4 lg4>
          <v-container fluid>
              <flight-search-form
              v-bind="formValuesToPass"
              @searchSubmited="search">
            </flight-search-form>
          </v-container>
        </v-flex>

        <v-flex ma-2 xs12 sm6 md7 lg4>
          <v-container fluid>
            <v-layout row>
              <v-flex xs12>
                <v-card class="layout column">
                  <v-toolbar card prominent color="info" dark>
                    <v-toolbar-title>Found these results:</v-toolbar-title>
                    <v-spacer></v-spacer>
                    <v-tooltip top>
                      <v-btn slot="activator" icon><v-icon>monetization_on</v-icon></v-btn>
                      <span>Sort by price</span>
                    </v-tooltip>
                    <v-tooltip top>
                      <v-btn slot="activator" icon><v-icon>access_time</v-icon></v-btn>
                      <span>Sort by flight time</span>
                    </v-tooltip>
                    <v-tooltip top>
                      <v-btn slot="activator" icon><v-icon>local_airport</v-icon></v-btn>
                      <span>Sort by number of changes</span>
                    </v-tooltip>
                  </v-toolbar>

                  <v-divider></v-divider>

                  <v-list two-line>
                    <flight-result-component
                      v-for="result in sortedByPrice"
                      v-bind="result"
                      :key="result.price">
                    </flight-result-component>
                  </v-list>
                </v-card>
              </v-flex>
            </v-layout>
          </v-container>
        </v-flex>
      </v-layout>
    </v-container>
  </v-content>
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
      sortByPrice: true,
      results: [],
      formValuesToPass: {
        isRoundTrip: JSON.parse(this.$route.query.isRoundTrip),
        isOneWay: JSON.parse(this.$route.query.isOneWay),
        origin: {airport_code: this.$route.query.originCode, city: this.$route.query.originFull},
        destination: {airport_code: this.$route.query.destinationCode, city: this.$route.query.destinationFull},
        departureDate: new Date(this.$route.query.departureDate),
        arrivalDate: new Date(this.$route.query.arrivalDate),
        priceMin: JSON.parse(this.$route.query.priceMin),
        priceMax: JSON.parse(this.$route.query.priceMax),
      },
    }
  },
  computed: {
    sortedByPrice: function() {
      function comparePrice(a,b) {
        if (a.result.price < b.result.price) { return -1; }
        else if (a.result.price > b.result.price) { return 1; }
        else return 0;
      }
      console.log(this.results.sort(comparePrice));
      return this.results.sort(comparePrice); // return sorted by price
    },
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
      let query = `/api/search?origin=${formValues.origin.airport_code}&destination=${formValues.destination.airport_code}`;

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
