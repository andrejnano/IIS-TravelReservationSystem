<template>
  <v-content>
    <loading :active.sync="isLoading" :can-cancel="true" :on-cancel="loadingCancel" :is-full-page="fullPage"></loading>
    <v-container fluid>
      <v-layout row wrap justify-center>
        <v-flex ma-2 xs12 sm5 md5 lg4>
          <flight-search-form v-bind="formValuesToPass" />
        </v-flex>
        <v-flex ma-2 xs12 sm6 md6 lg6 offset-lg1>
            <v-card>
              <v-img
                class="white--text"
                height="400px"
                src="https://images.unsplash.com/photo-1506012787146-f92b2d7d6d96?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=0d424e0c724d80f5f3b23c02201b8648&auto=format&fit=crop&w=1949&q=80"
                >
                <v-container fill-height fluid>
                  <v-layout align-end justify-start row fill-height>
                    <v-flex xs12>
                      <span class="headline">Find your perfect adventure!</span>
                    </v-flex>
                  </v-layout>
                </v-container>
              </v-img>
            <v-card-title>
              <p class="subheading font-weight-regular"> Your fabulous vacation is waiting for you! With our page you can flight all around the world. Just choose city and date and explore new places!</p>
              <h2>Select from these example flights</h2>
            </v-card-title>
            <v-card-text>
              <v-container fluid>
                <v-layout row wrap justify-start>
                  <v-btn
                  large
                  color="purple"
                  href="/searched?originCode=BUD&originFull=Budapest&destinationCode=VIE&destinationFull=Vienna&departureDate=2019-01-16&arrivalDate=2019-01-21&priceMin&priceMax&setClass=0">
                  Budapest to Vienna
                  </v-btn>
                  <v-btn
                    large
                    color="blue"
                    dark
                    href="/searched?originCode=Vie&originFull=Vienna&destinationCode=JFK&destinationFull=New%20York&tickets=2&setClass=0">
                    Vienna to New York
                  </v-btn>
                  <v-btn
                    large
                    color="green"
                    dark
                    href="/searched?originCode=HEL&originFull=Helsinki&destinationCode=KUL&destinationFull=Kuala%20Lumpur&tickets=2&setClass=0">
                    Helsinky to Kuala Lumpur
                  </v-btn>
                  <v-btn
                    large
                    color="orange"
                    dark
                    href="/searched?originCode=PRG&originFull=Prague&destinationCode=BRU&destinationFull=Brussels&tickets=2&setClass=0">
                    Prague to Brussels
                  </v-btn>
                  <v-btn
                    large
                    color="brown"
                    dark
                    href="/searched?originCode=DXB&originFull=Dubai&destinationCode=IST&destinationFull=Istanbul&tickets=2&setClass=0">
                    Dubai to Istanbul
                  </v-btn>
                  <v-btn
                    large
                    color="red"
                    dark
                    href="/searched?originCode=CFN&originFull=Dublin&destinationCode=BRQ&destinationFull=Brno&tickets=2&setClass=0">
                    Dublin to Brno
                  </v-btn>
                </v-layout>
              </v-container>
            </v-card-text>
          </v-card>
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
    seat_class: 0,
    tickets: 1,
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
