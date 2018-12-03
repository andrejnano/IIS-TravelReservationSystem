
<template>
  <v-layout row>
    <v-flex xs12 sm6 offset-sm3>
      <v-card>
        <v-toolbar color="cyan" dark>
          <v-btn v-if="tickets_active" @click="showReservations()">◀ back</v-btn>
          <v-toolbar-title v-if="reservations_active">My reservations</v-toolbar-title>
          <v-toolbar-title v-if="tickets_active">Tickets for reservation</v-toolbar-title>
          <v-btn v-if="!cur_res_pay" @click="payReservation()">pay</v-btn>

          <v-spacer></v-spacer>

        </v-toolbar>

        <v-list two-line>
          <template v-if="reservations_active" v-for="(item, index) in reservations">
            <v-list-tile
              :key="item.created_at"
              avatar
              @click="updateSelected(item)"
            >


              <v-list-tile-content>
                <v-list-tile-sub-title v-html="item.payment_status"></v-list-tile-sub-title>
                <v-list-tile-sub-title v-html="item.created_at"></v-list-tile-sub-title>
                <v-list-tile-sub-title v-html="item.total_cost"></v-list-tile-sub-title>
                <v-list-tile-sub-title v-html="item.count"></v-list-tile-sub-title>
              </v-list-tile-content>

              <!-- <v-list-tile-content>
                <v-list-tile-title v-html="item.payment_status"></v-list-tile-title>
              </v-list-tile-content> -->
            </v-list-tile>
            <v-divider
            ></v-divider>
          </template>

          <template v-if="tickets_active" v-for="(i, index) in cur_res.tickets">
            <v-list-tile
              :key="i.created_at"
              avatar
              @click="updateSelected(item)"
            >


              <v-list-tile-content>
                <v-list-tile-sub-title v-html="i.cost"></v-list-tile-sub-title>
                <v-list-tile-sub-title v-html="i.passanger"></v-list-tile-sub-title>
                <v-list-tile-sub-title v-html="i.flight"></v-list-tile-sub-title>
                <v-list-tile-sub-title v-html="i.seat"></v-list-tile-sub-title>
              </v-list-tile-content>

              <!-- <v-list-tile-content>
                <v-list-tile-title v-html="item.payment_status"></v-list-tile-title>
              </v-list-tile-content> -->
            </v-list-tile>
            <v-divider
            ></v-divider>
          </template>
        </v-list>
      </v-card>
    </v-flex>
  </v-layout>
</template>
<script>

import '@mdi/font/css/materialdesignicons.css';
import moment from 'moment';

import DebugBox from './DebugBox.vue';

import { library } from '@fortawesome/fontawesome-svg-core'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

import axios from 'axios'








export default {
  name: 'AddFlightForm',
  data() {
    return {
      reservations: [],
      reservations_active: false,
      tickets: [],
      tickets_active: false,
      cur_res: [],
      cur_res_pay: true,
    }
  },
  created () {
      axios.post('/api/my_reservations').then(res => {
          if (this.reservations.length == 0) {
            let rd = res.data.filled;
            for (var i = 0; i < rd.length; i++) {
              rd[i].pay = rd[i].payment_status;
              rd[i].payment_status = rd[i].payment_status ? "paid" : "not paid";
              rd[i].total_cost = String("total cost: ").concat(rd[i].total_cost).concat("€");
              rd[i].count = String("ticket count: ").concat(rd[i].count);
              this.reservations_active = true;
              this.reservations.push(rd[i]);
            }
          }
      });
  },
  components: {
    'debug-box': DebugBox,
    'font-awesome-icon': FontAwesomeIcon
  },
  methods: {
    updateSelected (item) {
        // this.selectedPlace = selectedItem;
        // this.showPlaces = true;
        console.log(item);
        this.tickets = item;
        this.reservations_active = false;
        this.tickets_active = true;
        this.cur_res = item;
        let cr = this.cur_res.tickets;
        for (var i = 0; i < cr.length; i++) {
          if (cr[i].updated === true)
            continue;
          cr[i].updated = true;
          cr[i].cost = String("cost: ").concat(cr[i].cost).concat("€");
          cr[i].passanger = String("").concat(cr[i].first_name).concat(" ").concat(cr[i].last_name).concat(" ").concat(cr[i].email);
          cr[i].flight = String("flight: ").concat(cr[i].flight.flight_number).concat(", departure: ").concat(cr[i].flight.departure_time).concat(", from: ").concat(cr[i].flight.origin).concat(", to: ").concat(cr[i].flight.destination);
          let seat_class;
          seat_class = cr[i].seat_class == "E" ? "economy" : (cr[i].seat_class == "B" ? "business" : "first");
          cr[i].seat = String("seat_class: ").concat(seat_class).concat(", seat_number: ").concat(cr[i].seat_number);
        }
        this.cur_res_pay = item.pay;
     },
    showReservations () {
        this.reservations_active = true;
        this.tickets_active = false;
        this.cur_res_pay = true;
     },
    payReservation () {
      console.log("reservation should be paid");
        axios.post('/api/pay', {
            res_id: this.cur_res.id
        });
        this.cur_res_pay = true,
        this.cur_res.payment_status = "paid";
        this.cur_res.pay = 1;
     }
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
