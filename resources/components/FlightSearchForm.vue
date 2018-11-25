<template>
  <div class='flight-search-wrap'>
    <form v-on:submit.prevent class='flight-search-form'>
      <h2 class='flight-search-form__heading'>Flight Search</h2>

      <div class='flight-search-form__group'>
        <button @click="setRoundTrip" class="flight-search-form__input-option" v-bind:class="{ selected: FORMisRoundTrip }">Round Trip</button>
        <button @click="setOneWay" class='flight-search-form__input-option' v-bind:class="{ selected: FORMisOneWay }">One way</button>
      </div>

      <div class='flight-search-form__group'>
        <div class='flight-search-form__input-text'>
          <label class='flight-search-form__input-text-label' for="origin">Origin:</label>
          <!-- <input class='flight-search-form__input-text-field' id="origin" v-model="origin" placeholder="From where?"> -->
          <model-list-select class='flight-search-form__input-text-field'
            :list="destinations"
            option-value="code"
            option-text="full"
            v-model="FORMorigin"
            placeholder="From where?"
            @searchchange="searchDestination">
          </model-list-select>
        </div>

        <div class='flight-search-form__input-text'>
          <label class='flight-search-form__input-text-label' for="destination">Destination:</label>
          <!-- <input class='flight-search-form__input-text-field' v-model="destination" placeholder="To where?"> -->
          <model-list-select class='flight-search-form__input-text-field'
            :list="destinations"
            option-value="code"
            option-text="full"
            v-model="FORMdestination"
            placeholder="To where?"
            @searchchange="searchDestination">
          </model-list-select>
        </div>
      </div>

      <div class='flight-search-form__group'>
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
        </div>

          <div class='flight-search-form__input-select'>
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
          </div>
      </div>

      <div class='flight-search-form__group'>
        <vue-slider v-bind="priceSlider" v-model="priceSlider.value"></vue-slider>
      </div>

      <button class='flight-search-form__input-btn btn' @click="searchSubmit">Search</button>
    </form>


  <!-- <debug-box
      :input='[
      {name: "Round trip", value: FORMisRoundTrip},
      {name: "One Way", value: FORMisOneWay},
      {name: "Origin", value: FORMorigin.code},
      {name: "Destination", value: FORMdestination.code},
      {name: "Min. price", value: priceSlider.value[0]},
      {name: "Max. price", value: priceSlider.value[1]}]'>
    </debug-box> -->

  </div>
</template>

<script>

// custom mutation of date class
Date.prototype.addDays = function(days) {
  var date = new Date(this.valueOf());
  date.setDate(date.getDate() + days);
  return date;
}

import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';

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

let searchExport = [];

export default {
  name: 'FlightSearchForm',
  props: [
    'isRoundTrip',
    'isOneWay',
    'origin',
    'destination',
    'departureDate',
    'arrivalDate',
    'priceMin',
    'priceMax'
  ],
  data() {
    return {
      FORMisRoundTrip: this.isRoundTrip,
      FORMisOneWay: this.isOneWay,
      FORMorigin: this.origin,
      FORMdestination: this.destination,
      FORMdepartureDate: this.departureDate,
      FORMarrivalDate: this.arrivalDate,
      destinationsFromApi: [
        { code: 'VIE', full: 'Vienna' },
        { code: 'JFK', full: 'New York' },
        { code: 'CDG', full: 'Paris' },
        { code: 'PRG', full: 'Prague' },
      ],
      destinations: [
        { code: 'VIE', full: 'Vienna' },
        { code: 'JFK', full: 'New York' },
        { code: 'CDG', full: 'Paris' },
        { code: 'PRG', full: 'Prague' },
      ],
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
      }
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
      this.destinations = this.destinationsFromApi;
    },
    searchSubmit() {
      this.$emit('searchSubmited', {
        isRoundTrip: this.FORMisRoundTrip,
        isOneWay: this.FORMisOneWay,
        origin: {code: this.FORMorigin.code, full: this.FORMorigin.full},
        destination: {code: this.FORMdestination.code, full: this.FORMdestination.full},
        departureDate: Date.parse(this.FORMdepartureDate),
        arrivalDate: Date.parse(this.FORMarrivalDate),
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
          departureDate: Date.parse(this.FORMdepartureDate),
          arrivalDate: Date.parse(this.FORMarrivalDate),
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

.flight-search-wrap {
  position: relative;
  margin: var(--space-md);
  padding: var(--space-md);
  background: #fff;
  border: 1px solid $color-border;
  border-radius: 5px;

  .flight-search-form {
    display: flex;
    flex-direction: column;
    justify-content: stretch;

    .flight-search-form__heading {
      text-align: center;
      color: $color-text-subtle;
    }

    .flight-search-form__group {
      position: relative;
      margin: var(--space-md) 0;
      display: flex;
      flex-direction: row;
      flex-wrap: wrap;
      justify-content: center;
    }

    .flight-search-form__input-text {
      cursor: pointer;
      position: relative;
      flex: 1;
      width: 170px;
      margin: var(--space-sm);
      text-align: left;

      .flight-search-form__input-text-field {
        cursor: pointer;
        display: block;
        border: 1px solid $color-border;
        outline: none;
        background: transparent;
        appearance: none;
        padding: var(--space-xs);
        min-width: 100%;
      }
      .flight-search-form__input-text-label {
        display: block;
        font-weight: bold;
        font-size: var(--text-sm);
      }
    }
    .flight-search-form__input-option {
      cursor: pointer;
      outline: none;
      appearance: none;
      flex-grow: 1;
      padding: var(--space-xxs);
      border: 1px solid $color-border;
      background-color: $gray-1;
    }

    .flight-search-form__input-option.selected {
      background-color: $white;
      color: $primary;
      font-weight: bold;
      @include materialShadow--1;
    }

    .flight-search-form__input-select {
      position: relative;
      flex: 1;
      width: 170px;
      margin: var(--space-sm);
      text-align: left;

      .flight-search-form__input-calendar-field {
        cursor: pointer;
        display: block;
        border: 1px solid $color-border;
        border-radius: 5px;
        outline: none;
        background: transparent;
        appearance: none;
        padding: var(--space-xs);
        width: 170px;
      }

      .flight-search-form__input-calendar-day-selected {
        .selected {
          background: $color-primary;
          color: $white;
          font-weight: bold;
          border-radius: 100%;
        }
      }

      .flight-search-form__input-select-label {
        display: block;
        font-weight: bold;
        font-size: var(--text-sm);
      }
    }
    .flight-search-form__input-btn {
        margin: var(--space-md);
        position: relative;
    }
  }
}


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
</style>
