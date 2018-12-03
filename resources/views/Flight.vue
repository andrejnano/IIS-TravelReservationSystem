<template>
  <v-content>
    <v-dialog
      v-model="isLoading"
      hide-overlay
      persistent
      width="400"
    >
      <v-card
        color="info"
        dark
      >
        <v-card-text>
           {{ loadingMsg }}
          <v-progress-linear
            indeterminate
            color="white"
            class="mb-0"
          ></v-progress-linear>
        </v-card-text>
      </v-card>
    </v-dialog>
    <v-container fluid>
      <v-layout justify-center column>
        <v-flex xs12>
          <v-card v-if="loaded">
            <v-card-title
              class="headline"
              primary-title
              v-html="expandedTitle"
            >
            </v-card-title>

            <v-card-text ref="printMe" >
              <v-list three-line subheader :light="printingNow">

                <v-divider></v-divider>
                <v-subheader>Departing flights</v-subheader>

                <v-divider inset></v-divider>
                <v-list-tile avatar>
                  <v-list-tile-avatar>
                    <img :src="logoThere0">
                  </v-list-tile-avatar>
                  <v-list-tile-content>
                    <v-list-tile-sub-title v-html="expandedTopThereFrom0"></v-list-tile-sub-title>
                    <v-list-tile-title v-html="expandedTitleThereFrom0"></v-list-tile-title>
                    <v-list-tile-sub-title v-html="expandedSubTitleThereFrom0"></v-list-tile-sub-title>
                  </v-list-tile-content>
                  <v-list-tile-content>
                    <v-list-tile-sub-title v-html="expandedMiddleThere0"></v-list-tile-sub-title>
                  </v-list-tile-content>
                  <v-list-tile-content>
                    <v-list-tile-sub-title v-html="expandedTopThereTo0"></v-list-tile-sub-title>
                    <v-list-tile-title v-html="expandedTitleThereTo0"></v-list-tile-title>
                    <v-list-tile-sub-title v-html="expandedSubTitleThereTo0"></v-list-tile-sub-title>
                  </v-list-tile-content>
                </v-list-tile>

                <v-divider inset></v-divider>

                <v-list-tile v-if="result.there.hasOwnProperty('1')" color="purple">
                  <v-list-tile-content>
                    <v-list-tile-sub-title v-html="layoverThere"></v-list-tile-sub-title>
                  </v-list-tile-content>
                </v-list-tile>

                <v-divider inset></v-divider>

                <v-list-tile avatar v-if="result.there.hasOwnProperty('1')">
                  <v-list-tile-avatar>
                    <img :src="logoThere1">
                  </v-list-tile-avatar>
                  <v-list-tile-content>
                    <v-list-tile-sub-title v-html="expandedTopThereFrom1"></v-list-tile-sub-title>
                    <v-list-tile-title v-html="expandedTitleThereFrom1"></v-list-tile-title>
                    <v-list-tile-sub-title v-html="expandedSubTitleThereFrom1"></v-list-tile-sub-title>
                  </v-list-tile-content>
                  <v-list-tile-content>
                    <v-list-tile-sub-title v-html="expandedMiddleThere1"></v-list-tile-sub-title>
                  </v-list-tile-content>
                   <v-list-tile-content>
                    <v-list-tile-sub-title v-html="expandedTopThereTo1"></v-list-tile-sub-title>
                    <v-list-tile-title v-html="expandedTitleThereTo1"></v-list-tile-title>
                    <v-list-tile-sub-title v-html="expandedSubTitleThereTo1"></v-list-tile-sub-title>
                  </v-list-tile-content>
                </v-list-tile>

                <v-divider inset></v-divider>

                <template v-if="result.hasOwnProperty('back')">

                  <v-subheader>Returning flights</v-subheader>

                  <v-list-tile v-if="result.back.hasOwnProperty('0')">
                    <v-list-tile-avatar>
                      <img :src="logoBack0">
                    </v-list-tile-avatar>
                    <v-list-tile-content>
                      <v-list-tile-sub-title v-html="expandedTopBackFrom0"></v-list-tile-sub-title>
                      <v-list-tile-title v-html="expandedTitleBackFrom0"></v-list-tile-title>
                      <v-list-tile-sub-title v-html="expandedSubTitleBackFrom0"></v-list-tile-sub-title>
                    </v-list-tile-content>
                    <v-list-tile-content>
                      <v-list-tile-sub-title v-html="expandedMiddleBack0"></v-list-tile-sub-title>
                    </v-list-tile-content>
                    <v-list-tile-content>
                      <v-list-tile-sub-title v-html="expandedTopBackTo0"></v-list-tile-sub-title>
                      <v-list-tile-title v-html="expandedTitleBackTo0"></v-list-tile-title>
                      <v-list-tile-sub-title v-html="expandedSubTitleBackTo0"></v-list-tile-sub-title>
                    </v-list-tile-content>
                  </v-list-tile>

                  <v-divider inset></v-divider>

                  <v-list-tile v-if="result.back.hasOwnProperty('1')">
                    <v-list-tile-content>
                      <v-list-tile-sub-title v-html="layoverBack"></v-list-tile-sub-title>
                    </v-list-tile-content>
                  </v-list-tile>

                  <v-divider inset></v-divider>

                  <v-list-tile v-if="result.back.hasOwnProperty('1')">
                    <v-list-tile-avatar>
                      <img :src="logoBack1">
                    </v-list-tile-avatar>
                    <v-list-tile-content>
                      <v-list-tile-sub-title v-html="expandedTopBackFrom1"></v-list-tile-sub-title>
                      <v-list-tile-title v-html="expandedTitleBackFrom1"></v-list-tile-title>
                      <v-list-tile-sub-title v-html="expandedSubTitleBackFrom1"></v-list-tile-sub-title>
                    </v-list-tile-content>
                    <v-list-tile-content>
                      <v-list-tile-sub-title v-html="expandedMiddleBack1"></v-list-tile-sub-title>
                    </v-list-tile-content>
                    <v-list-tile-content>
                      <v-list-tile-sub-title v-html="expandedTopBackTo1"></v-list-tile-sub-title>
                      <v-list-tile-title v-html="expandedTitleBackTo1"></v-list-tile-title>
                      <v-list-tile-sub-title v-html="expandedSubTitleBackTo1"></v-list-tile-sub-title>
                    </v-list-tile-content>
                  </v-list-tile>
                </template>

              </v-list>
            </v-card-text>

            <v-divider></v-divider>

            <v-card-actions>
              <v-spacer></v-spacer>
              <span v-html="expandedBottomDescription"></span>
              <v-spacer></v-spacer>
            </v-card-actions>
          </v-card>
        </v-flex>
      </v-layout>
    </v-container>

    <v-container v-if="!loggedIn && !createdReservation && loaded" fluid>
      <div class='headline text-xs-center'>
        You must be logged in to create a reservation
      </div>
      <v-layout justify-center column>
        <v-flex xs12>
          <login>
          </login>
          <div class='headline text-xs-center'>
            or
          </div>
        </v-flex>

       <v-flex xs12>
          <register>
          </register>
       </v-flex>
      </v-layout>
    </v-container>

    <v-container fluid >
      <v-layout justify-center align-center>
        <v-flex xs6 v-if="loggedIn && loaded" ma-2>
          <v-form ref="form" v-model="valid" lazy-validation>
            <template v-for="(passenger, i) in passengers">
              <v-container :key="i" ma-2 fluid>
                <div class='ma-2 headline'> {{ i + 1}}. passenger </div>
                <v-card>
                  <v-card-text>
                    <v-text-field
                      v-model="passengers[i].first_name"
                      :rules="nameRules"
                      label="First name"
                      required
                    ></v-text-field>
                    <v-text-field
                      v-model="passengers[i].last_name"
                      :rules="nameRules"
                      label="Last name"
                      required
                    ></v-text-field>
                    <v-text-field
                      v-model="passengers[i].email"
                      :rules="emailRules"
                      label="E-mail"
                      required
                    ></v-text-field>
                  </v-card-text>
                </v-card>
              </v-container>
            </template>
          </v-form>
        </v-flex>
         <v-flex xs6 ma-2>
          <v-container ma-2 fluid>
            <v-card ma-2>
              <v-card-text class="text-xs-center">
                Reservation summary
              </v-card-text>

              <v-data-table
                class="elevation-1"
                :items="summary"
                :hide-actions="true"
              >
                <v-progress-linear slot="progress" color="blue" indeterminate></v-progress-linear>
                <template slot="items" slot-scope="props">
                  <td>{{ props.item.name }}</td>
                  <td class="text-xs-right">{{ props.item.value }}</td>
                </template>

              </v-data-table>
            </v-card>
            <v-card ma-2>
              <v-card-text class="text-xs-center">
                  <v-btn
                    ripple
                    color="success"
                    @click="reserveFlight"
                    :disabled="!valid || !loggedIn"
                    large
                  >
                    Create reservation for this flight
                </v-btn>
                <v-btn v-if="!loggedIn" @click="clear">clear</v-btn>
              </v-card-text>
            </v-card>
          </v-container>
         </v-flex>
      </v-layout>
    </v-container>

    <v-dialog
      v-model="createdReservation"
      hide-overlay
      persistent
      color="success"
      width="90%"
      height="60%"
    >
      <v-card>
        <v-card-text>
          <v-alert
            :value="true"
            type="success"
          >
            SUCCESS!! Reservation with id <strong>{{ reservationID }}</strong> was created!
          </v-alert>
         Would you like to print an itinerary ?
        </v-card-text>
        <v-card-actions>
          <v-btn medium color="secondary" @click="printItinerary">Print itinerary</v-btn>
          <v-btn medium color="gray" href="/">Go back to search</v-btn>
          <v-btn medium color="gray" href="/profile">View my reservations</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

  </v-content>
</template>

<script>
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';
import axios from 'axios';
axios.defaults.headers.post['Content-Type'] = 'multipart/form-data';

import Login from './Login.vue';
import Register from './Register.vue';

// format the date string to just display hours and minutes
function onlyHoursMinutes(dateString) {
  return new Date(dateString).toLocaleTimeString().replace(/([\d]+:[\d]{2})(:[\d]{2})(.*)/, "$1$3");
}

export default {
  name: 'Flight',
  components: {
    Login,
    Register,
  },
  data() {
    return {
      isLoading: true,
      loadingMsg: "",
      passengers: [],
      flightParams: {
        ft_1: this.$route.query.ft_1 != null ? this.$route.query.ft_1 : null,
        ft_2: this.$route.query.ft_2 != null ? this.$route.query.ft_2 : null,
        fb_1: this.$route.query.fb_1 != null ? this.$route.query.fb_1 : null,
        fb_2: this.$route.query.fb_2 != null ? this.$route.query.fb_2 : null,
        class: this.$route.query.class != null ? Number(this.$route.query.class): null,
        tickets: this.$route.query.tickets != null ? Number(this.$route.query.tickets) : null,
      },
      result: {},
      loaded: false,
      loggedIn: false,
      reservationID: null,
      valid: true,
      emailRules: [
        v => !!v || 'E-mail is required',
        v => /.+@.+/.test(v) || 'E-mail must be valid'
      ],
      nameRules: [
        v => !!v || 'Name is required',
        v => v.length <= 14 || 'Name must be less than 10 characters'
      ],
      summary: [],
      output: null,
      printingNow: false,
      createdReservation: false,
    }
  },
  methods: {
    printItinerary() {
      // changes theme to light, waits for component reload, than calls PDF creation as callback
      this.printingNow = true;
      this.isLoading = true;
      this.loadingMsg = "Printing itinerary...";
      setTimeout(this.generatePDF2Canvas, 1000);
    },
    generatePDF2Canvas: async function(){

      const el = this.$refs.printMe;
      const options = {
        type: 'dataURL',
        windowWidth: 1300,
        windowHeight: 760,
      }
      this.output = await this.$html2canvas(el, options);

      let doc = new jsPDF({
        orientation: 'p',
        unit: 'mm',
        format: 'a4',
      });
      doc.text('Itinerary for a reservation #' + this.reservationID, 10, 10);
      doc.setFontSize(10);
      doc.fromHTML(this.expandedTitle, 10, 20);
      doc.addImage(this.output, 'JPEG', 10, 40, 210, 100);
      doc.save('itinerary_' + this.reservationID + '.pdf');
      this.printingNow = false;
      this.isLoading = false;
    },
    clear () {
      this.$refs.form.reset();
    },
    getReservation() {
      this.isLoading = true;
      this.loadingMsg = "Creating temporary reservation...";
      axios.post('/api/reservation', {total_price: this.totalPrice }).then((response) => {
        if (response.status == 200) {
            this.loggedIn = true;
            this.reservationID = response.data.new_reservation_id;
            console.log('%c LOGGED IN, RESERVATION w/ ID: ' + this.reservationID + ' & price: ' + this.totalPrice + ' CREATED! ', 'background: #00ff00; color: #ffffff');
            this.isLoading = false;
          } else {
            console.log('%c NOT LOGGED IN! ', 'background: #ff0000; color: #ffffff');
            this.loggedIn = false;
            this.isLoading = false;
          }
      }).catch((error) => { this.isLoading = false; });
    },
    getFlight(params) {

      this.isLoading = true;
      this.loadingMsg = "Loading flight information...";
      this.loaded = false;

      let query = `/api/flight?`;

      if (params.ft_1 != null && params.ft_1 != '' )
      {
        query += `&ft_1=${params.ft_1}`;
      }
      if (params.ft_2 != null && params.ft_2 != '' )
      {
        query += `&ft_2=${params.ft_2}`;
      }
      if (params.fb_1 != null && params.fb_1 != '' )
      {
        query += `&fb_1=${params.fb_1}`;
      }
      if (params.fb_2 != null && params.fb_2 != '' )
      {
        query += `&fb_2=${params.fb_2}`;
      }
      if (params.tickets != null && params.tickets != '' )
      {
        query += `&tickets=${params.tickets}`;
      }

      if (params.class != null)
      {
        if (params.class == 0)
        {
          query += `&class=economy`;
        }
        else if (params.class == 1)
        {
          query += `&class=business`;
        }
        else if (params.class == 2)
        {
          query += `&class=first`;
        }
      }

      axios.get(query).then((response) => {

        if (response.status == 200) {
          console.log({query});
          console.log('%c FLIGHT FOUND! ', 'background: #00ff00; color: #ffffff');
        } else {
          console.log('%c FLIGHT NOT FOUND! ', 'background: #ff0000; color: #ffffff');
          return;
        }
        let responseResults = response.data;

        responseResults.forEach(flight => {
          this.result = Object.assign({}, flight);
        });

        let ticket_ids = this.result.there.ticket_ids;
        var i = 0;

        // iterate ticket_ids and create new passengers
        if (this.result.hasOwnProperty('back'))
        {
          // round trip passengers have 2 ids assigned
          for (i = 0; i < ticket_ids.length; i += 2) {

            let newPassenger = {
              id_there: ticket_ids[i],
              id_back: ticket_ids[i+1],
              first_name: '',
              last_name: '',
              email: ''
            };
            this.passengers.push(newPassenger);
          }
        }
        else
        {
          for (i = 0; i < ticket_ids.length; i++) {

            let newPassenger = {
              id_there: ticket_ids[i],
              first_name: '',
              last_name: '',
              email: ''
            };
            this.passengers.push(newPassenger);
          }
        }

        this.summary.push({ name: "Passengers", value: this.passengers.length});
        this.summary.push({ name: "Single ticket price", value: this.result.total_price + "€"});
        this.summary.push({ name: "", value: this.passengers.length + " x " + this.result.total_price + "€"});
        this.summary.push({ name: "Total price", value: this.totalPrice + "€"});

        this.loaded = true;
        this.isLoading = false;

        this.getReservation();
      });
    },
    reserveFlight() {
      if (this.$refs.form.validate()) {

        // Round Trip
        if (this.result.hasOwnProperty('back')) {

          var i = 0;
          for(i = 0; i < this.passengers.length; i++)
          {
            // reservation for the flight there
            axios.post('/api/reserve', {
              res_id: this.reservationID,
              ticket_id: this.passengers[i].id_there,
              first_name: this.passengers[i].first_name,
              last_name: this.passengers[i].last_name,
              email: this.passengers[i].email,
            }).then((response) => {
              if (response.status == 200) {
                console.log('%c New reservation for a passenger was made! ', 'background: #00ff00; color: #ffffff');
              } else {
                console.log('%c Could not make a new reservaton for this passenger! ', 'background: #ff0000; color: #ffffff');
              }
            }).catch((error) => {
              console.log("Post request error on /api/reserve : " + error);
            });

            // reservation for the flight back
            axios.post('/api/reserve', {
              res_id: this.reservationID,
              ticket_id: this.passengers[i].id_back,
              first_name: this.passengers[i].first_name,
              last_name: this.passengers[i].last_name,
              email: this.passengers[i].email,
            }).then((response) => {
              if (response.status == 200) {
                console.log('%c New reservation for a passenger was made! ', 'background: #00ff00; color: #ffffff');
              } else {
                console.log('%c Could not make a new reservaton for this passenger! ', 'background: #ff0000; color: #ffffff');
              }
            }).catch((error) => {
              console.log("Post request error on /api/reserve : " + error);
            });
          }
          this.createdReservation = true;
        }
        else { // One Way
          var i = 0;
          for(i = 0; i < this.passengers.length; i++)
          {
            axios.post('/api/reserve', {
              res_id: this.reservationID,
              ticket_id: this.passengers[i].id_there,
              first_name: this.passengers[i].first_name,
              last_name: this.passengers[i].last_name,
              email: this.passengers[i].email,
            }).then((response) => {
              if (response.status == 200) {
                console.log('%c New reservation for a passenger was made! ', 'background: #00ff00; color: #ffffff');
              } else {
                console.log('%c Could not make a new reservaton for this passenger! ', 'background: #ff0000; color: #ffffff');
              }
            }).catch((error) => {
              console.log("Post request error on /api/reserve : " + error);
            });
          }
          this.createdReservation = true;
        }


      }
    }
  },
  created() {
    this.getFlight(this.flightParams);
  },
  computed: {
    totalPrice: function() {
      return this.passengers.length * this.result.total_price;
    },
    smallDescription: function() {

      var output = "";
      //class to string
      let classString = "";
      if (this.result.there['0'].seat_class == "economy") {
        classString = "<span class='bronze'>economy class</span>";
      } else if (this.result.there['0'].seat_class == "business") {
        classString = "<span class='silver'>business class</span>";
      } else if (this.result.there['0'].seat_class == "first") {
        classString = "<span class='gold'>first class</span>";
      }
      else {
        classString = "<span class='error'>unknown class</span>";
      }

      output += "Class: " + classString;
      output += " | <span class='mdi mdi-timer'></span> ± <strong>" + this.result.total_time + " hours</strong>";

      return output;
    },
    bigDescription: function() {
      var output = "";

      const isRoundTrip = this.result.hasOwnProperty('back');

      output += this.thereDetailedTitle;

      if (isRoundTrip) {
        output += " <br>" + this.backDetailedTitle;
      }

      return output;
    },
    thereTitle: function() {
      var output = "";
      if (this.result.there.hasOwnProperty('1')) {
        // s prestupom
        output += this.result.there['0'].origin.city + " → ";
        output += this.result.there['1'].destination.city;
      } else {
        // bez prestupu
        output += this.result.there['0'].origin.city + " → ";
        output += this.result.there['0'].destination.city;
      }
      return output;
    },
    backTitle: function() {
      var output = "";
      if (this.result.there.hasOwnProperty('1')) {
        // s prestupom
        output += this.result.there['0'].origin.city + " → ";
        output += this.result.there['1'].destination.city;
      } else {
        // bez prestupu
        output += this.result.there['0'].origin.city + " → ";
        output += this.result.there['0'].destination.city;
      }
      return output;
    },
    thereDetailedTitle: function() {

      var output = "There: ";
      var there = this.result.there;

      const isConnectingThere = this.result.there.hasOwnProperty('1');

      output += there['0'].origin.airport + " <strong>" + onlyHoursMinutes(there['0'].departure_time) + "</strong> → ";

      if (isConnectingThere)
      {
        output += there['1'].origin.airport + " <strong>" + onlyHoursMinutes(there['1'].departure_time) + "</strong> (stop) → ";
        output += there['1'].destination.airport + " " + onlyHoursMinutes(there['1'].arrival_time);
      }
      else
      {
        output += there['0'].destination.airport + " <strong>" + onlyHoursMinutes(there['0'].arrival_time) + "</strong>";
      }

      return output;
    },
    backDetailedTitle: function() {
      var output = "Back: ";
      var back = this.result.back;

      const isConnectingBack= this.result.back.hasOwnProperty('1');

      output += back['0'].origin.airport + "  <strong>" + onlyHoursMinutes(back['0'].departure_time) + "</strong> → ";

      if (isConnectingBack)
      {
        output += back['1'].origin.airport + " <strong>" + onlyHoursMinutes(back['1'].departure_time) + "</strong> (stop) → ";
        output += back['1'].destination.airport + " <strong>" + onlyHoursMinutes(back['1'].arrival_time) + "</strong>";
      }
      else
      {
        output += back['0'].destination.airport + " <strong>" + onlyHoursMinutes(back['0'].arrival_time) + "</strong>";
      }

      return output;
    },

    logoThere0: function() {
      return `../images/${this.result.there['0'].airline.id_logo}.png`;
    },
    logoThere1: function() {
      return `../images/${this.result.there['1'].airline.id_logo}.png`;
    },
    logoBack0: function() {
      return `../images/${this.result.back['0'].airline.id_logo}.png`;
    },
    logoBack1: function() {
      return `../images/${this.result.back['1'].airline.id_logo}.png`;
    },

    expandedTopThere0: function() {
      var segment = this.result.there[0];
      return `Flight number: <strong>${segment.flight_number}</strong>`;
    },
    expandedTopThere1: function() {
      var segment = this.result.there[1];
      return `Flight number: <strong>${segment.flight_number}</strong>`;
    },
      expandedTopBack0: function() {
      var segment = this.result.back[0];
      return `Flight number: <strong>${segment.flight_number}</strong>`;
    },
    expandedTopBack1: function() {
      var segment = this.result.back[1];
      return `Flight number: <strong>${segment.flight_number}</strong>`;
    },

    expandedTitleThere0: function() {
      var segment = this.result.there[0];
      return `<span class='mdi mdi-airplane-takeoff'></span> ${segment.origin.city} (${segment.origin.airport}) <strong> ${onlyHoursMinutes(segment.departure_time)} </strong> →  ${segment.destination.city} (${segment.destination.airport}) <strong> ${onlyHoursMinutes(segment.arrival_time)} </strong> <span class='mdi mdi-airplane-landing'></span>`;
    },
    expandedTitleThere1: function() {
      var segment = this.result.there[1];
      return `<span class='mdi mdi-airplane-takeoff'></span> ${segment.origin.city} (${segment.origin.airport}) <strong> ${onlyHoursMinutes(segment.departure_time)} </strong> →  ${segment.destination.city} (${segment.destination.airport}) <strong> ${onlyHoursMinutes(segment.arrival_time)} </strong> <span class='mdi mdi-airplane-landing'></span>`;
    },
      expandedTitleBack0: function() {
      var segment = this.result.back[0];
      return `<span class='mdi mdi-airplane-takeoff'></span> ${segment.origin.city} (${segment.origin.airport}) <strong> ${onlyHoursMinutes(segment.departure_time)} </strong> →  ${segment.destination.city} (${segment.destination.airport}) <strong> ${onlyHoursMinutes(segment.arrival_time)} </strong> <span class='mdi mdi-airplane-landing'></span>`;
    },
    expandedTitleBack1: function() {
      var segment = this.result.back[1];
      return `<span class='mdi mdi-airplane-takeoff'></span> ${segment.origin.city} (${segment.origin.airport}) <strong> ${onlyHoursMinutes(segment.departure_time)} </strong> →  ${segment.destination.city} (${segment.destination.airport}) <strong> ${onlyHoursMinutes(segment.arrival_time)} </strong> <span class='mdi mdi-airplane-landing'></span>`;
    },

    expandedSubTitleThere0: function() {
      var segment = this.result.there[0];
      return `<span class='mdi mdi-timer'></span> ${segment.flight_time} | <span class='mdi mdi-airplane'></span> ${segment.airplane.producer} ${segment.airplane.model} | ${segment.airline.full_name} ${segment.airline.nationality}`;
    },
    expandedSubTitleThere1: function() {
      var segment = this.result.there[1];
      return `<span class='mdi mdi-timer'></span> ${segment.flight_time} | <span class='mdi mdi-airplane'></span> ${segment.airplane.producer} ${segment.airplane.model} | ${segment.airline.full_name} ${segment.airline.nationality}`;
    },
      expandedSubTitleBack0: function() {
      var segment = this.result.back[0];
      return `<span class='mdi mdi-timer'></span> ${segment.flight_time} | <span class='mdi mdi-airplane'></span> ${segment.airplane.producer} ${segment.airplane.model} | ${segment.airline.full_name} ${segment.airline.nationality}`;
    },
    expandedSubTitleBack1: function() {
      var segment = this.result.back[1];
      return `<span class='mdi mdi-timer'></span> ${segment.flight_time} | <span class='mdi mdi-airplane'></span> ${segment.airplane.producer} ${segment.airplane.model} | ${segment.airline.full_name} ${segment.airline.nationality}`;
    },

    layoverThere: function () {
      var time1 = new Date(this.result.there[0].arrival_time);
      var time2 = new Date(this.result.there[1].departure_time);

      var difference = time2 - time1;

      return `<span class='mdi mdi-clock'></span> Layover time: ${onlyHoursMinutes(difference)} @ <span class='mdi mdi-airport'></span> ${this.result.there[0].destination.city} International Airport (${this.result.there[0].destination.airport})`;

    },
    layoverBack: function () {
      var time1 = new Date(this.result.back[0].arrival_time);
      var time2 = new Date(this.result.back[1].departure_time);

      var difference = time2 - time1;

      return `<span class='mdi mdi-clock'></span> Layover time: ${onlyHoursMinutes(difference)} @ <span class='mdi mdi-airport'></span> ${this.result.back[0].destination.city} International Airport (${this.result.back[0].destination.airport})`;
    },


    expandedTitle: function() {
      var output = "";
      var there = this.result.there;

      const isRoundTrip = this.result.hasOwnProperty('back');

      if (isRoundTrip) {
        output += "Details of a roundtrip from " + "&nbsp;<strong>" + there[0].origin.city + "</strong>&nbsp;" + " to";
      }
      else {
        output += "Details of a one way trip " + "&nbsp;<strong>" + there[0].origin.city + "</strong>&nbsp;" + " to";
      }

      const isConnectingThere = this.result.there.hasOwnProperty('1');

      if (isConnectingThere)
      {
        output += "&nbsp;<strong>" + there[1].destination.city + "</strong>&nbsp;";
      }
      else {
        output += "&nbsp;<strong>" + there[0].destination.city + "</strong>&nbsp;";
      }

      return output;
    },

    expandedBottomDescription: function() {

      var output = "";
      //class to string
      let classString = "";
      if (this.result.there['0'].seat_class == "economy") {
        classString = "<span class='bronze'>economy class</span>";
      } else if (this.result.there['0'].seat_class == "business") {
        classString = "<span class='silver'>business class</span>";
      } else if (this.result.there['0'].seat_class == "first") {
        classString = "<span class='gold'>first class</span>";
      }
      else {
        classString = "<span class='error'>unknown class</span>";
      }

       output += "Total travel time: <span class='mdi mdi-timer'></span> about <strong>" + this.result.total_time + " hours</strong>";
       output += "&nbsp;-&nbsp;" + classString + "&nbsp;-&nbsp;<span class='mdi mdi-dark mdi-briefcase-check'></span>";


      return output;
    },

// To
// From

    expandedTopThereFrom0: function() {
      var segment = this.result.there[0];
      return `<span class='mdi mdi-airplane-takeoff'></span>&nbsp;<strong>${segment.departure_time}</strong>`;
    },
    expandedTopThereFrom1: function() {
      var segment = this.result.there[1];
      return `<span class='mdi mdi-airplane-takeoff'></span>&nbsp;<strong>${segment.departure_time}</strong>`;
    },
    expandedTopBackFrom0: function() {
      var segment = this.result.back[0];
      return `<span class='mdi mdi-airplane-takeoff'></span>&nbsp;<strong>${segment.departure_time}</strong>`;
    },
    expandedTopBackFrom1: function() {
      var segment = this.result.back[1];
      return `<span class='mdi mdi-airplane-takeoff'></span>&nbsp;<strong>${segment.departure_time}</strong>`;
    },

    expandedTopThereTo0: function() {
      var segment = this.result.there[0];
      return `<span class='mdi mdi-airplane-landing'></span>&nbsp;<strong>${segment.arrival_time}</strong>`;
    },
    expandedTopThereTo1: function() {
      var segment = this.result.there[1];
      return `<span class='mdi mdi-airplane-landing'></span>&nbsp;<strong>${segment.arrival_time}</strong>`;
    },
      expandedTopBackTo0: function() {
      var segment = this.result.back[0];
      return `<span class='mdi mdi-airplane-landing'></span>&nbsp;<strong>${segment.arrival_time}</strong>`;
    },
    expandedTopBackTo1: function() {
      var segment = this.result.back[1];
      return `<span class='mdi mdi-airplane-landing'></span>&nbsp;<strong>${segment.arrival_time}</strong>`;
    },


    expandedTitleThereFrom0: function() {
      var segment = this.result.there[0];
      return `<span class='mdi mdi-map-marker'></span><strong>&nbsp;${segment.origin.city} (${segment.origin.airport})</strong> ${segment.origin.country}`;
    },
    expandedTitleThereFrom1: function() {
      var segment = this.result.there[1];
      return `<span class='mdi mdi-map-marker'></span><strong>&nbsp;${segment.origin.city} (${segment.origin.airport})</strong> ${segment.origin.country}`;
    },
      expandedTitleBackFrom0: function() {
      var segment = this.result.back[0];
      return `<span class='mdi mdi-map-marker'></span><strong>&nbsp;${segment.origin.city} (${segment.origin.airport})</strong> ${segment.origin.country}`;
    },
    expandedTitleBackFrom1: function() {
      var segment = this.result.back[1];
      return `<span class='mdi mdi-map-marker'></span><strong>&nbsp;${segment.origin.city} (${segment.origin.airport})</strong> ${segment.origin.country}`;
    },

    expandedSubTitleThereFrom0: function() {
      var segment = this.result.there[0];
      return `${segment.airline.full_name} ${segment.airline.nationality}`;
    },
    expandedSubTitleThereFrom1: function() {
      var segment = this.result.there[1];
      return `${segment.airline.full_name} ${segment.airline.nationality}`;
    },
    expandedSubTitleBackFrom0: function() {
      var segment = this.result.back[0];
      return ` ${segment.airline.full_name} ${segment.airline.nationality}`;
    },
    expandedSubTitleBackFrom1: function() {
      var segment = this.result.back[1];
      return `${segment.airline.full_name} ${segment.airline.nationality}`;
    },



    // To


    expandedTitleThereTo0: function() {
      var segment = this.result.there[0];
      return `<span class='mdi mdi-map-marker'></span><strong>&nbsp;${segment.destination.city} (${segment.destination.airport})</strong> ${segment.destination.country}`;
    },
    expandedTitleThereTo1: function() {
      var segment = this.result.there[1];
      return `<span class='mdi mdi-map-marker'></span><strong>&nbsp;${segment.destination.city} (${segment.destination.airport})</strong> ${segment.destination.country}`;
    },
      expandedTitleBackTo0: function() {
      var segment = this.result.back[0];
      return `<span class='mdi mdi-map-marker'></span><strong>&nbsp;${segment.destination.city} (${segment.destination.airport})</strong> ${segment.destination.country}`;
    },
    expandedTitleBackTo1: function() {
      var segment = this.result.back[1];
      return `<span class='mdi mdi-map-marker'></span><strong>&nbsp;${segment.destination.city} (${segment.destination.airport})</strong> ${segment.destination.country}`;
    },

    expandedSubTitleThereTo0: function() {
      var segment = this.result.there[0];
      return `${segment.airline.full_name} ${segment.airline.nationality}`;
    },
    expandedSubTitleThereTo1: function() {
      var segment = this.result.there[1];
      return `${segment.airline.full_name} ${segment.airline.nationality}`;
    },
      expandedSubTitleBackTo0: function() {
      var segment = this.result.back[0];
      return `${segment.airline.full_name} ${segment.airline.nationality}`;
    },
    expandedSubTitleBackTo1: function() {
      var segment = this.result.back[1];
      return `${segment.airline.full_name} ${segment.airline.nationality}`;
    },

    // middle connecting info

    expandedMiddleThere0: function() {
      var segment = this.result.there[0];
      return `<span class='mdi mdi-timer'></span> ${segment.flight_time} | <span class='mdi mdi-airplane'></span> ${segment.airplane.producer} ${segment.airplane.model}`;
    },
    expandedMiddleThere1: function() {
      var segment = this.result.there[1];
      return `<span class='mdi mdi-timer'></span> ${segment.flight_time} | <span class='mdi mdi-airplane'></span> ${segment.airplane.producer} ${segment.airplane.model}`;
    },
    expandedMiddleBack0: function() {
      var segment = this.result.back[0];
      return `<span class='mdi mdi-timer'></span> ${segment.flight_time} | <span class='mdi mdi-airplane'></span> ${segment.airplane.producer} ${segment.airplane.model}`;
    },
    expandedMiddleBack1: function() {
      var segment = this.result.back[1];
      return `<span class='mdi mdi-timer'></span> ${segment.flight_time} | <span class='mdi mdi-airplane'></span> ${segment.airplane.producer} ${segment.airplane.model}`;
    },

  },
}

</script>

<style>

/* for printing to PDF */
.theme--dark.v-list .v-list__tile__sub-title {
  display: inline-block !important;
}
.theme--light.v-list .v-list__tile__sub-title {
  display: inline-block !important;
}


</style>
