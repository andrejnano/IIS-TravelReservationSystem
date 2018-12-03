<template>
  <v-content>
    <v-dialog
      v-model="isLoading"
      hide-overlay
      persistent
      width="300"
    >
      <v-card
        color="primary"
        dark
      >
        <v-card-text>
          Searching for flights...
          <v-progress-linear
            indeterminate
            color="white"
            class="mb-0"
          ></v-progress-linear>
        </v-card-text>
      </v-card>
    </v-dialog>

    <v-container fluid>
      <v-layout ma-2 row align-start fill-height>
        <v-flex ma-2 xs12 sm4 md4 lg4>
          <v-container fluid>
              <flight-search-form
              v-bind="formValuesToPass"
              @searchSubmited="search">
            </flight-search-form>
          </v-container>
        </v-flex>

        <v-flex ma-2 xs12 sm8 md8 lg8>
          <v-container fluid>
            <v-layout row>
              <v-flex xs12>
                <v-card class="layout column">
                  <v-toolbar card prominent>
                    <v-toolbar-title>Found these results:</v-toolbar-title>
                    <v-spacer></v-spacer>

                    <v-btn-toggle v-model="sortToggle">
                      <v-tooltip top>
                      <v-btn slot="activator" icon><v-icon>monetization_on</v-icon></v-btn>
                      <span>Sort by price</span>
                    </v-tooltip>
                    <v-tooltip top>
                      <v-btn slot="activator" icon><v-icon>access_time</v-icon></v-btn>
                      <span>Sort by flight time</span>
                    </v-tooltip>
                    </v-btn-toggle>
                  </v-toolbar>

                  <v-divider></v-divider>

                  <v-list two-line>

                    <template v-if="sortToggle == 0">
                      <flight-result-component
                        v-for="(result, i) in sortedByPrice"
                        :result="result"
                        :key="i">
                      </flight-result-component>
                    </template>

                    <template v-if="sortToggle == 1">
                      <flight-result-component
                        v-for="(result, i) in sortedByTime"
                        :result="result"
                        :key="i">
                      </flight-result-component>
                    </template>

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

export default {
  name: 'ResultsView',
  data() {
    return {
      sortToggle: 0,
      isLoading: false,
      fullPage: true,
      results: [],
      formValuesToPass: {
        origin: {airport_code: this.$route.query.originCode, city: this.$route.query.originFull},
        destination: {airport_code: this.$route.query.destinationCode, city: this.$route.query.destinationFull},
        departureDate: this.$route.query.departureDate,
        arrivalDate: this.$route.query.arrivalDate != '' ? this.$route.query.arrivalDate : null,
        priceMin: this.$route.query.priceMin ? Number(this.$route.query.priceMin) : null,
        priceMax: this.$route.query.priceMax ? Number(this.$route.query.priceMax) : null,
        setClass: this.$route.query.setClass ? Number(this.$route.query.setClass) : null,
        tickets: this.$route.query.tickets ? Number(this.$route.query.tickets) : null,
      },
    }
  },
  computed: {
    // TODO: sort there + back together
    sortedByPrice: function() {
      function comparePrice(a,b) {
        if (a.total_price < b.total_price) { return -1; }
        else if (a.total_price > b.total_price) { return 1; }
        else return 0;
      }
      console.log(this.results.sort(comparePrice));
      return this.results.sort(comparePrice); // return sorted by price
    },
    sortedByTime: function() {
      function compareTime(a,b) {
        if (a.total_time < b.total_time) { return -1; }
        else if (a.total_time > b.total_time) { return 1; }
        else return 0;
      }
      console.log(this.results.sort(compareTime));
      return this.results.sort(compareTime);
    },
  },
  methods: {
    search(formValues) {
      // perform search query to the API
      this.isLoading = true;
      this.results = [];  // reset the results

      // construct the query to API
      let query = `/api/search?`;
      query += `origin=${formValues.origin.airport_code}`;
      query += `&destination=${formValues.destination.airport_code}`;

      if (formValues.departureDate != null && formValues.departureDate != '')
      {
        query += `&departure_date=${formValues.departureDate}`;
      }

      if (formValues.arrivalDate != '' && formValues.arrivalDate != null )
      {
        query += `&arrival_date=${formValues.arrivalDate}`;
        query += `&min_t=0`;
      }

      if (formValues.priceMax != null)
      {
        query += `&max_price=${formValues.priceMax}`;
      }

      if (formValues.priceMin != null)
      {
        query += `&min_price=${formValues.priceMin}`;
      }

      if (formValues.setClass != null)
      {
        if(formValues.setClass == 0)
        {
          query += `&class=economy`;
        }
        else if(formValues.setClass == 1)
        {
          query += `&class=business`;
        }
        else if(formValues.setClass == 2)
        {
          query += `&class=first`;
        }
      }

      if (formValues.hasOwnProperty('tickets'))
      {
        query += `&tickets=${formValues.tickets}`;
      }

      console.log({query});

      // perform the query
      axios.get(query).then((response) => {

        if (response.status == 200) {
          console.log("QUERY OK! : 200");
        } else {
          return;
        }
        // extract only the data part
        let responseResults = response.data;

        responseResults.forEach(flightResult => {

          this.results.push( flightResult );

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
