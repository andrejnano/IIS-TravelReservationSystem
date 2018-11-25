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

function FlightResult({ origin, destination, price}) {
  this.origin = origin;
  this.destination = destination;
  this.price = price;
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

  export default {
    name: 'ResultsView',
    data() {
      return {
        isLoading: false,
        fullPage: true,
        results: [],
        formValuesToPass: {
          isRoundTrip: this.$route.query.isRoundTrip,
          isOneWay: this.$route.query.isOneWay,
          origin: {code: this.$route.query.originCode, full: this.$route.query.originFull},
          destination: {code: this.$route.query.destinationCode, full: this.$route.query.destinationFull},
          departureDate: new Date(this.$route.query.departureDate),
          arrivalDate: new Date(this.$route.query.arrivalDate),
          priceMin: this.$route.query.priceMin,
          priceMax: this.$route.query.priceMax,
        },
      }
    },
    methods: {
      search(formValues) {
        // perform search query to the API
        this.isLoading = true;
        this.results = [];  // reset the results

        setTimeout(() => {

          // TODO: implement API query
          // window.axios.get('/search/{args}).then(({ data }) => {
          //   data.forEach(flightResult => {
          //     this.flightResults.push(new FlightResult(flightResult));
          //   });
          //     window.axios.put(`/api/cruds/${id}`, { color }).then(() => {
          //
          //   this.cruds.find(crud => crud.id === id).color = color;
          // });

          // tmp solution
          let prepResult = {
            origin: formValues.origin.code,
            destination: formValues.destination.code,
            price: Math.floor(Math.random() * 1000)
          };
            // here -> axios

            // add found result to the list
            this.results.push( { result: new FlightResult(prepResult) });
            this.isLoading = false;

            console.log(this.results);
          },1000);
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
