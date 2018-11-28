<template>
  <v-card class="layout column" light>
      <v-toolbar card prominent color="info" dark>
        <v-toolbar-title><v-icon>search</v-icon>Search for flights</v-toolbar-title>
      </v-toolbar>
      <v-divider></v-divider>
      <v-card-text class="text-xs-center">
        <v-btn-toggle v-model="toggleRoundTrip">
          <v-btn flat @click="setRoundTrip">
            Round trip
          </v-btn>
          <v-btn flat @click="setOneWay">
            One way
          </v-btn>
        </v-btn-toggle>
      </v-card-text>
      <v-divider></v-divider>
      <v-card-text>
        <v-autocomplete
          v-model="FORMorigin"
          :items="destinations"
          :loading="isLoading"
          :search-input.sync="searchDestination"
          color="white"
          hide-no-data
          hide-selected
          item-text="full"
          item-value="code"
          label="Origin"
          placeholder="From where?"
          prepend-icon="mdi-flight-takeoff"
          return-object
        ></v-autocomplete>
      </v-card-text>
      <v-divider></v-divider>
      <v-expand-transition>
        <v-list v-if="model" class="blue lighten-3">
          <v-list-tile
            v-for="(field, i) in fields"
            :key="i"
          >
            <v-list-tile-content>
              <v-list-tile-title v-text="field.value"></v-list-tile-title>
              <v-list-tile-sub-title v-text="field.key"></v-list-tile-sub-title>
            </v-list-tile-content>
          </v-list-tile>
        </v-list>
      </v-expand-transition>

      <v-card-text>
        <v-autocomplete
        v-model="FORMdestination"
        :items="destinations"
        :loading="isLoading"
        :search-input.sync="searchDestination"
        color="white"
        hide-no-data
        hide-selected
        item-text="full"
        item-value="code"
        label="Origin"
        placeholder="To where?"
        prepend-icon="mdi-flight-landing"
        return-object
        ></v-autocomplete>
      </v-card-text>
      <v-divider></v-divider>
      <v-expand-transition>
        <v-list v-if="model" class="blue lighten-3">
          <v-list-tile
            v-for="(field, i) in fields"
            :key="i"
          >
            <v-list-tile-content>
              <v-list-tile-title v-text="field.value"></v-list-tile-title>
              <v-list-tile-sub-title v-text="field.key"></v-list-tile-sub-title>
            </v-list-tile-content>
          </v-list-tile>
        </v-list>
      </v-expand-transition>

      <!-- calendars -->

      <v-card-text>
        <v-container fluid>
          <v-layout row>
            <v-flex xs6>
              <v-menu
                :close-on-content-click="false"
                v-model="departureDateMenu"
                :nudge-right="40"
                lazy
                transition="scale-transition"
                offset-y
                full-width
                min-width="290px"
              >
                <v-text-field
                  slot="activator"
                  v-model="FORMdepartureDate"
                  label="Departure date"
                  prepend-icon="event"
                  readonly
                ></v-text-field>

                <v-date-picker v-model="FORMdepartureDate" @input="menu2 = false"></v-date-picker>
              </v-menu>
            </v-flex>
            <v-flex xs6>
              <v-menu
                :close-on-content-click="false"
                v-model="departureDateMenu"
                :nudge-right="40"
                lazy
                transition="scale-transition"
                offset-y
                full-width
                min-width="290px"
              >
                <v-text-field
                  slot="activator"
                  v-model="FORMdepartureDate"
                  label="Departure date"
                  prepend-icon="event"
                  readonly
                ></v-text-field>

                <v-date-picker v-model="FORMdepartureDate" @input="menu2 = false"></v-date-picker>
              </v-menu>
            </v-flex>
          </v-layout>
        </v-container>
    </v-card-text>

    <v-card-text>
      <v-layout row wrap>
        <v-flex xs12>
          <v-subheader class="pl-0">Max: </v-subheader>
          <v-slider
            v-model="slider"
            always-dirty
            hint="Set the maximum price, you are willing to pay"
            persistent-hint
            thumb-label="always"
            :max="sliderMax"
            :min="sliderMin"
          ></v-slider>
        </v-flex>
      </v-layout>
    </v-card-text>

      <!-- <div class='flight-search-form__group'>
        <div class='flight-search-form__input-select'>
          <label class='flight-search-form__input-select-label' for="departure-date">Departure date:</label>
          <datepicker :value="departureDate"
            :monday-first="true"
            :input-class="calendar.inputClass"
            :calendar-class="calendar.calendarClass"
            id='departure-date'
            class='flight-search-form__input-select-field'
            v-model="FORMdepartureDate"
            name="departureDate">
          </datepicker>
        </div> -->

          <!-- <div class='flight-search-form__input-select'>
            <transition name="fade">
              <label v-if="FORMisRoundTrip" class='flight-search-form__input-select-label' for="arrival-date" >
                Arrival date:
              </label>
            </transition>
            <transition name="fade">
              <datepicker  v-if="FORMisRoundTrip"
                :monday-first="true"
                :value="arrivalDate"
                id='arrival-date'
                :input-class="calendar.inputClass"
                :calendar-class="calendar.calendarClass"
                class='flight-search-form__input-select-field'
                v-model="FORMarrivalDate"
                name="arrivalDate">
              </datepicker>
            </transition>
          </div> -->

      <div class='flight-search-form__group'>
        <vue-slider v-bind="priceSlider" v-model="priceSlider.value"></vue-slider>
      </div>

      <v-card-text>
        <v-btn
          :loading="loadingSubmit"
          :disabled="loadingSubmit"
          color="info"
          @click="searchSubmit"
          large
        >
          Search
          <span slot="submitLoader" class="custom-loader">
            <v-icon light>cached</v-icon>
          </span>
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
import '@mdi/font/css/materialdesignicons.css'

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


import axios from 'axios'

export default {
  name: 'FlightSearchForm',
  props: {
    isRoundTrip: Boolean,
    isOneWay: Boolean,
    origin: Object,
    destination: Object,
    departureDate: Date,
    arrivalDate: Date,
    priceMin: Number,
    priceMax: Number,
  },
  data() {
    return {
      submitLoader: null,
      loadingSubmit: false,
      departureDateMenu: false,
      arrivalDateMenu: false,
      toggleRoundTrip: 1,
      FORMisRoundTrip: this.isRoundTrip,
      FORMisOneWay: this.isOneWay,
      FORMorigin: this.origin,
      FORMdestination: this.destination,
      FORMdepartureDate: this.departureDate,
      FORMarrivalDate: this.arrivalDate,
      destinations: [
        { code: 'VIE', full: 'Vienna' },
        { code: 'JFK', full: 'New York' },
        { code: 'CDG', full: 'Paris' },
        { code: 'PRG', full: 'Prague' },
        { code: 'HEL', full: 'Helsinki'},
        { code: 'LGW', full: 'London'},
      ],
      searchText: '',
      slider: 450,
      sliderMin: 1,
      sliderMax: 3000,
      priceSlider: {
        value: [
          this.priceMin,
          this.priceMax
        ],
        width: "100%",
        height: 8,
        dotSize: 16,
        min: 0,
        max: 3000,
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
      model: null,
      search: null,
      isLoading: false,
      entries: []
    }
  },
  computed: {
    fields() {
      if (!this.model) return []

      return Object.keys(this.model).map(key => {
        return {
          key,
          value: this.model[key] || 'n/a'
        }
      })
    },
    items () {
      return this.entries.map(entry => {
          const Description = entry.Description.length > this.descriptionLimit
            ? entry.Description.slice(0, this.descriptionLimit) + '...'
            : entry.Description

          return Object.assign({}, entry, { Description })
      })
    },
  },
  watch: {
    search (val) {
      // Items have already been loaded
        if (this.items.length > 0) return;
        // Items have already been requested
        if (this.isLoading) return;

        this.isLoading = true;

        // Lazily load input items
        axios.get('/airports')
          .then(res => {
            const { count, entries } = res.data
            this.count = count
            this.entries = entries
          })
          .catch(err => {
            console.log(err)
          })
          .finally(() => (this.isLoading = false))
    },
    loader () {
      const l = this.loader;
      this[l] = !this[l]

      setTimeout(( () => (this[l] = false), 3000));

      this.loader = null;
    }
  },
  methods: {
    setRoundTrip() {
      this.FORMisRoundTrip = true;
      this.FORMisOneWay = false;
    },
    setOneWay() {
      this.FORMisRoundTrip = false;
      this.FORMisOneWay = true;
    },
    searchDestination (searchText) {
      this.searchText = searchText;
      // TODO: add query to API
      // this.destinations = this.destinationsFromApi;
    },
    searchSubmit() {
      this.$emit('searchSubmited', {
        isRoundTrip: this.FORMisRoundTrip,
        isOneWay: this.FORMisOneWay,
        origin: {code: this.FORMorigin.code, full: this.FORMorigin.full},
        destination: {code: this.FORMdestination.code, full: this.FORMdestination.full},
        departureDate: this.FORMdepartureDate.getTime(),
        arrivalDate: this.FORMarrivalDate.getTime(),
        priceMin: this.priceSlider.value[0],
        priceMax: this.priceSlider.value[1],
      });

      // change the URL and view to /searched?...
      this.$router.push({
        path: '/searched',
        query: {
          isRoundTrip: this.FORMisRoundTrip,
          isOneWay: this.FORMisOneWay,
          originCode: this.FORMorigin.code,
          originFull: this.FORMorigin.full,
          destinationCode: this.FORMdestination.code,
          destinationFull: this.FORMdestination.full,
          departureDate: this.FORMdepartureDate.getTime(),
          arrivalDate: this.FORMarrivalDate.getTime(),
          priceMin: this.priceSlider.value[0],
          priceMax: this.priceSlider.value[1],
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
@import '../design/style';

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
