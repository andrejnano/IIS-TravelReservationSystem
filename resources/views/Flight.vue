<template>
  <v-content>
    <v-container fluid>
      <v-layout justify-center column>
        <v-flex xs12>
          <v-card>
            <v-card-title
              class="headline grey lighten-2"
              primary-title
              v-html="expandedTitle"
            >
            </v-card-title>

            <v-card-text>
              <v-list three-line subheader>

                <v-divider></v-divider>
                <v-subheader>Departing flights</v-subheader>

                <v-divider inset></v-divider>
                <v-list-tile avatar>
                  <v-list-tile-avatar>
                    <img :src="logoThere0">
                  </v-list-tile-avatar>
                  <v-list-tile-content>
                    <v-list-tile-sub-title v-html="expandedTopThere0"></v-list-tile-sub-title>
                    <v-list-tile-title v-html="expandedTitleThere0"></v-list-tile-title>
                    <v-list-tile-sub-title v-html="expandedSubTitleThere0"></v-list-tile-sub-title>
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
                    <v-list-tile-sub-title v-html="expandedTopThere1"></v-list-tile-sub-title>
                    <v-list-tile-title v-html="expandedTitleThere1"></v-list-tile-title>
                    <v-list-tile-sub-title v-html="expandedSubTitleThere1"></v-list-tile-sub-title>
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
                      <v-list-tile-sub-title v-html="expandedTopBack0"></v-list-tile-sub-title>
                      <v-list-tile-title v-html="expandedTitleBack0"></v-list-tile-title>
                      <v-list-tile-sub-title v-html="expandedSubTitleBack0"></v-list-tile-sub-title>
                    </v-list-tile-content>
                  </v-list-tile>

                  <v-divider></v-divider>

                  <v-list-tile v-if="result.back.hasOwnProperty('1')">
                    <v-list-tile-content>
                      <v-list-tile-sub-title v-html="layoverBack"></v-list-tile-sub-title>
                    </v-list-tile-content>
                  </v-list-tile>

                  <v-divider></v-divider>

                  <v-list-tile v-if="result.back.hasOwnProperty('1')">
                    <v-list-tile-avatar>
                      <img :src="logoBack1">
                    </v-list-tile-avatar>
                    <v-list-tile-content>
                      <v-list-tile-sub-title v-html="expandedTopBack1"></v-list-tile-sub-title>
                      <v-list-tile-title v-html="expandedTitleBack1"></v-list-tile-title>
                      <v-list-tile-sub-title v-html="expandedSubTitleBack1"></v-list-tile-sub-title>
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
              <v-btn
                ripple
                dark
                color="success"
                large
              >
                Create reservation for this flight &nbsp; <strong> {{ result.total_price }} €</strong>
              </v-btn>
            </v-card-actions>
          </v-card>
        </v-flex>
      </v-layout>
    </v-container>
  </v-content>
</template>

<script>
import axios from 'axios';

// format the date string to just display hours and minutes
function onlyHoursMinutes(dateString) {
  return new Date(dateString).toLocaleTimeString().replace(/([\d]+:[\d]{2})(:[\d]{2})(.*)/, "$1$3");
}

export default {
  name: 'Flight',
  data() {
    return {
      flightParams: {
        ft_1: this.$route.query.ft_1 != null ? this.$route.query.ft_1 : null,
        ft_2: this.$route.query.ft_2 != null ? this.$route.query.ft_2 : null,
        fb_1: this.$route.query.fb_1 != null ? this.$route.query.fb_1 : null,
        fb_2: this.$route.query.fb_2 != null ? this.$route.query.fb_2 : null,
      },
      result: {}
    }
  },
  methods: {
    getFlight(params) {

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

      query += `&tickets=1`;
      query += `&class=0`;

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
          this.result = flight;
        });

      });
    }
  },
  created() {
    this.getFlight(this.flightParams);
  },
  computed: {
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
        output += "Round trip flight from " + "&nbsp;<strong>" + there[0].origin.city + "</strong>&nbsp;" + " to";
      }
      else {
        output += "One way flight from " + "&nbsp;<strong>" + there[0].origin.city + "</strong>&nbsp;" + " to";
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

  },
}

</script>

<style>

</style>
