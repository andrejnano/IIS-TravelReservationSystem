<template>
  <v-card class="layout column">

      <!-- TOOLBAR -->
      <v-toolbar card prominent>
        <v-toolbar-title><v-icon>search</v-icon>Search for flights</v-toolbar-title>
      </v-toolbar>

      <!-- ROUNDTRIP/ONEWAY TOGGLE -->
      <v-card-text class="text-xs-center">
        <v-btn-toggle v-model="toggleRoundTrip" mandatory>
          <v-btn flat>
            Round Trip
          </v-btn>
          <v-btn flat>
            One way
          </v-btn>
        </v-btn-toggle>
      </v-card-text>

      <v-divider></v-divider>

      <!-- ORIGIN AUTOCOMPLETE -->
      <v-card-text>
        <v-autocomplete
        v-model="FORMorigin"
        :items="items"
        :search-input.sync="searchOriginAirport"
        :loading="originLoading"
        item-text="city"
        item-value="airport_code"
        label="Origin"
        hint="Select a city"
        persistent-hint
        return-object
        prepend-icon="mdi-airplane-takeoff"
        color="secondary"
        >
        </v-autocomplete>
      </v-card-text>

      <!-- DESTINATION AUTOCOMPLETE -->
      <v-card-text>
        <v-autocomplete
        v-model="FORMdestination"
        :items="items"
        :search-input.sync="searchDestinationAirport"
        :loading="destinationLoading"
        item-text="city"
        item-value="airport_code"
        label="Destination"
        hint="Select a city"
        persistent-hint
        return-object
        prepend-icon="mdi-airplane-landing"
        color="secondary"
        >
        </v-autocomplete>
      </v-card-text>

      <v-divider></v-divider>

      <!-- calendars -->
      <v-card-text>
        <v-menu
          v-model="departureDateMenu"
          :close-on-content-click="false"
          full-width
          max-width="290"
        >
          <v-text-field
            slot="activator"
            :value="computedDepartureDateFormatted"
            clearable
            @click:clear="clearDepartureDate"
            label="Date of departure"
            prepend-icon="mdi-calendar"
            color="secondary"
            readonly
          ></v-text-field>
          <v-date-picker
            v-model="FORMdepartureDate"
            @change="departureDateMenu = false"
            color="secondary"
            light
          ></v-date-picker>
        </v-menu>
      </v-card-text>

      <v-card-text v-if="toggleRoundTrip == 0">
        <v-menu
          v-model="arrivalDateMenu"
          :close-on-content-click="false"
          full-width
          max-width="290"
        >
          <v-text-field
            slot="activator"
            :value="computedArrivalDateFormatted"
            clearable
            label="Date of arrival"
            prepend-icon="mdi-calendar"
            color="secondary"
            readonly
          ></v-text-field>
          <v-date-picker
            v-model="FORMarrivalDate"
            @change="arrivalDateMenu = false"
            color="secondary"
            light
            :min="FORMdepartureDate"
          ></v-date-picker>
        </v-menu>
      </v-card-text>

      <v-divider></v-divider>

      <v-card-text class="text-xs-center">
        <v-container>
          <v-card-title>Seating class</v-card-title>
          <v-btn-toggle dense v-model="toggleClass" mandatory>
            <v-btn flat>
              Economy
            </v-btn>
            <v-btn flat>
              Business
            </v-btn>
            <v-btn flat>
              First
            </v-btn>
          </v-btn-toggle>
        </v-container>
      </v-card-text>

      <v-divider></v-divider>

      <v-card-text class="text-xs-center">
        <v-container>
          <v-card-title>Number of passengers</v-card-title>
          <v-select
            dense
            :items="numberOfPassengers"
            label="Number of passengers"
            v-model="FORMtickets"
            solo
            color="secondary"
            prepend-icon="mdi-account"
          ></v-select>
        </v-container>
      </v-card-text>

      <v-divider></v-divider>

      <v-card-text>
        <v-card-title>Price interval</v-card-title>
        <v-container class="text-xs-center">
          <div class='flight-search-form__group'>
            <vue-slider style="margin-top: 1rem;" v-bind="priceSlider" v-model="priceSlider.value"></vue-slider>
          </div>
        </v-container>
      </v-card-text>

      <v-divider></v-divider>

      <!-- SUBMIT BUTTON  -->
      <v-card-text class="text-xs-center">
        <v-btn
          color="secondary"
          @click="searchSubmit"
          large
          ripple
        >
          <v-icon light>mdi-magnify</v-icon><span class="display">Search for flights</span>
        </v-btn>
      </v-card-text>

  </v-card>
</template>

<script>
// custom mutation of date class
Date.prototype.addDays = function(days) {
  var date = new Date(this.valueOf());
  date.setDate(date.getDate() + days);
  return date;
}

import '@mdi/font/css/materialdesignicons.css';
import moment from 'moment';
import axios from 'axios'

import DebugBox from './DebugBox.vue';
import { ModelListSelect } from 'vue-search-select';
import Datepicker from 'vuejs-datepicker';
import vueSlider from 'vue-slider-component';

import { library } from '@fortawesome/fontawesome-svg-core'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import {
  faPlaneDeparture,
  faPlaneArrival
} from '@fortawesome/free-solid-svg-icons'

library.add(faPlaneDeparture)
library.add(faPlaneArrival)


export default {
  name: 'FlightSearchForm',
  props: {
    origin: Object,
    destination: Object,
    departureDate: String,
    arrivalDate: String,
    priceMin: Number,
    priceMax: Number,
    seat_class: Number,
    tickets: Number,
  },
  data() {
    return {
      submitLoader: null,
      loadingSubmit: false,
      departureDateMenu: false,
      arrivalDateMenu: false,
      toggleRoundTrip: this.arrivalDate != '' ? 0 : 1,
      toggleClass: this.seat_class != null ? this.seat_class : 0,
      FORMorigin: this.origin,
      FORMdestination: this.destination,
      FORMdepartureDate: this.departureDate,
      FORMarrivalDate: this.arrivalDate,
      FORMtickets: this.tickets,
      numberOfPassengers: [1,2,3,4,5,6,7,8],
      searchText: '',
      priceSlider: {
        value: [
          this.priceMin,
          this.priceMax
        ],
        width: "100%",
        height: 8,
        dotSize: 16,
        min: 0,
        max: 5000,
        disabled: false,
        show: true,
        useKeyboard: true,
        tooltip: "always",
        formatter: "{value}€",
        enableCross: false,
        mergeFormatter: "{value1}€ ~ {value2}€",
        bgStyle: {
          "backgroundColor": "#fff",
          "boxShadow": "inset 0.5px 0.5px 3px 1px rgba(0,0,0,.36)"
        },
        tooltipStyle: {
          "backgroundColor": "#666",
          "borderColor": "#666"
        },
        processStyle: {
          "backgroundColor": "#4D84F4"
        },
      },
      calendar: {
        inputClass: 'flight-search-form__input-calendar-field',
        calendarClass: 'flight-search-form__input-calendar-day-selected'
      },
      // Destination picking autocomplete MODEL + Logic setup
      airports: [],
      // experiment
      originLoading: false,
      destinationLoading: false,
      airportEntries: [],
      searchOriginAirport: null,
      searchDestinationAirport: null,
    }
  },
  computed: {
    computedDepartureDateFormatted () {
      return this.FORMdepartureDate ? moment(this.FORMdepartureDate).format('dddd, MMMM Do YYYY') : '';
    },
    computedArrivalDateFormatted () {
      return this.FORMarrivalDate ? moment(this.FORMarrivalDate).format('dddd, MMMM Do YYYY') : '';
    },
    items () {
      return this.airportEntries;
    }
  },
  created () {
      axios.get('/api/airports').then(res => {
        this.airports = res.data;
        this.airportEntries = this.airports;
      });
  },
  watch: {
    searchOriginAirport (val) {
      if(this.items.length > 0) return;
      if(this.originLoading) return;
      this.originLoading = true;
      setTimeout(() => {
          this.airportEntries = this.airports;
          this.originLoading = false;
      }, 500);
    },
    searchDestinationAirport (val) {
      if(this.items.length > 0) return;
      if(this.destinationLoading) return;
      this.destinationLoading = true;
      setTimeout(() => {
          this.airportEntries = this.airports;
          this.destinationLoading = false;
      }, 500);
    },
    loader () {
      const l = this.loader;
      this[l] = !this[l]
      setTimeout(( () => (this[l] = false), 3000));
      this.loader = null;
    }
  },
  methods: {
    clearDepartureDate () {
      this.FORMdepartureDate = "";
      console.log("Clear date");
    },
    querySelections (v) {
        this.loadingOrigin = true
        // Simulated ajax query
        setTimeout(() => {
          this.originItems = this.airports.filter(e => {
            return (e || '').toLowerCase().indexOf((v || '').toLowerCase()) > -1
          })
          this.loadingOrigin = false;
        }, 500)
      },
    searchSubmit() {
      // convert class to a string format from toggle

      this.$emit('searchSubmited', {
        origin: {airport_code: this.FORMorigin.airport_code, city: this.FORMorigin.city, country: this.FORMorigin.country},
        destination: {airport_code: this.FORMdestination.airport_code, city: this.FORMdestination.city, country: this.FORMdestination.country},
        departureDate: this.FORMdepartureDate != "" ? this.FORMdepartureDate : null,
        arrivalDate: this.toggleRoundTrip == 0 ? this.FORMarrivalDate : null,
        priceMin: this.priceSlider.value[0],
        priceMax: this.priceSlider.value[1],
        seat_class: this.toggleClass,
        tickets: this.FORMtickets,
      });

      this.$router.push({
        path: '/searched',
        query: {
          originCode: this.FORMorigin.airport_code,
          originFull: this.FORMorigin.city,
          destinationCode: this.FORMdestination.airport_code,
          destinationFull: this.FORMdestination.city,
          departureDate: this.FORMdepartureDate,
          arrivalDate: this.toggleRoundTrip == 0 ? this.FORMarrivalDate : null,
          priceMin: this.priceSlider.value[0],
          priceMax: this.priceSlider.value[1],
          seat_class: this.toggleClass,
          tickets: this.FORMtickets,
        },
      });
    }
  },
  components: {
    'debug-box': DebugBox,
    ModelListSelect,
    Datepicker,
    vueSlider,
    'font-awesome-icon': FontAwesomeIcon
  }
}

</script>

<style lang="scss">

// global stylesheet
// @import '../design/style';

/* Enter and leave animations can use different */
/* durations and timing functions.              */
.slide-fade-enter-active {
  transition: all .3s ease;
}
.slide-fade-leave-active {
  transition: all .8s cubic-bezier(1.0, 0.5, 0.8, 1.0);
}
.slide-fade-enter, .slide-fade-leave-to
/* .slide-fade-leave-active below version 2.1.8 */ {
  transform: translateX(10px);
  opacity: 0;
}

.custom-loader {
    animation: loader 1s infinite;
    display: flex;
  }
  @-moz-keyframes loader {
    from {
      transform: rotate(0);
    }
    to {
      transform: rotate(360deg);
    }
  }
  @-webkit-keyframes loader {
    from {
      transform: rotate(0);
    }
    to {
      transform: rotate(360deg);
    }
  }
  @-o-keyframes loader {
    from {
      transform: rotate(0);
    }
    to {
      transform: rotate(360deg);
    }
  }
  @keyframes loader {
    from {
      transform: rotate(0);
    }
    to {
      transform: rotate(360deg);
    }
  }
</style>
