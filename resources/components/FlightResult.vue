
<template>
  <div>
    <v-list-tile avatar @click="expandDetails" slot="activator" ripple>
      <v-list-tile-avatar>
        <img :src="logoThere0">
      </v-list-tile-avatar>
      <v-list-tile-content>
        <v-list-tile-title v-html="thereTitle"></v-list-tile-title>
        <v-list-tile-sub-title v-html="smallDescription"></v-list-tile-sub-title>
      </v-list-tile-content>
      <v-spacer></v-spacer>
      <v-btn
        @click="openFlight"
        dark
        color="green"
        large
      >
        {{ result.total_price }} €
      </v-btn>
    </v-list-tile>
    <v-dialog v-model="dialog" width="900">
      <v-card>
        <v-card-title
          class="headline"
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

            <v-divider></v-divider>

            <template v-if="result.hasOwnProperty('back')">

              <v-subheader>Returning flights</v-subheader>

              <v-divider inset></v-divider>

              <v-list-tile avatar v-if="result.back.hasOwnProperty('0')">
                <v-list-tile-avatar>
                  <img :src="logoBack0">
                </v-list-tile-avatar>
                <v-list-tile-content>
                  <v-list-tile-sub-title v-html="expandedTopBack0"></v-list-tile-sub-title>
                  <v-list-tile-title v-html="expandedTitleBack0"></v-list-tile-title>
                  <v-list-tile-sub-title v-html="expandedSubTitleBack0"></v-list-tile-sub-title>
                </v-list-tile-content>
              </v-list-tile>

              <v-divider inset></v-divider>

              <v-list-tile v-if="result.back.hasOwnProperty('1')">
                <v-list-tile-content>
                  <v-list-tile-sub-title v-html="layoverBack"></v-list-tile-sub-title>
                </v-list-tile-content>
              </v-list-tile>

              <v-divider inset></v-divider>

              <v-list-tile avatar v-if="result.back.hasOwnProperty('1')">
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
            @click="openFlight"
            dark
            color="green"
            large
          >
            Book this flight for &nbsp; <strong> {{ result.total_price }} €</strong>
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script>


// format the date string to just display hours and minutes
function onlyHoursMinutes(dateString) {
  return new Date(dateString).toLocaleTimeString().replace(/([\d]+:[\d]{2})(:[\d]{2})(.*)/, "$1$3");
}

export default {
  props: ['result'],
  data: () => ({
    show: false,
    dialog: false,
  }),
  created() {
    console.log("got a result");
    console.log({result: this.result})
  },
  watch: {
    dialog (val) {
      val || this.close()
    }
  },
  computed: {
    smallDescription: function() {

      var output = "";
      //class to string
      let classString = "";
      if (this.result.there['0'].seat_class === "economy") {
        classString = "<span class='bronze'>economy class</span>";
      } else if (this.result.there['0'].seat_class === "business") {
        classString = "<span class='silver'>business class</span>";
      } else if (this.result.there['0'].seat_class === "first") {
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
      output += " | <small> <span class='mdi mdi-calendar'></span> ";
      output += this.result.there['0'].departure_time.substring(0,10) + "</small>";
      if (this.result.there.hasOwnProperty('1')) {
        output += " | <span class='mdi mdi-autorenew'></span> <small>with changing</small>";
      }
      else if (this.result.hasOwnProperty('back') && this.result.back.hasOwnProperty('1')){
        output += " | <span class='mdi mdi-autorenew'></span> <small>with changing</small>";
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
      return `Flight number: <strong>${segment.flight_number}</strong>` + " | <span class='mdi mdi-calendar'></span> " + segment.departure_time.substring(0,10);
    },
    expandedTopThere1: function() {
      var segment = this.result.there[1];
      return `Flight number: <strong>${segment.flight_number}</strong>` + " | <span class='mdi mdi-calendar'></span> " + segment.departure_time.substring(0,10);
    },
      expandedTopBack0: function() {
      var segment = this.result.back[0];
      return `Flight number: <strong>${segment.flight_number}</strong>` + " | <span class='mdi mdi-calendar'></span> " + segment.departure_time.substring(0,10);
    },
    expandedTopBack1: function() {
      var segment = this.result.back[1];
      return `Flight number: <strong>${segment.flight_number}</strong>` + " | <span class='mdi mdi-calendar'></span> " + segment.departure_time.substring(0,10);
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
  methods: {
    close () {
      this.dialog = false;
    },
    openFlight() {

      // QUERY TO /api/flight

      let query = {};

      const isRoundTrip = this.result.hasOwnProperty('back');
      const isConnectingThere = this.result.there.hasOwnProperty('1');

      let there = this.result.there;

      // flight there, first segment
      query.ft_1 = there[0].flight_number;

      if (isConnectingThere)
      {
        // flight there, second segment
        query.ft_2 = there[1].flight_number;
      }

      if (isRoundTrip)
      {
        const isConnectingBack = this.result.back.hasOwnProperty('1');
        let back = this.result.back;

        query.fb_1 = back[0].flight_number;

        if (isConnectingBack)
        {
          query.fb_2 = back[1].flight_number;
        }
      }

      if (there['0'].seat_class == "economy")
      {
        query.class = 0;
      }
      else if (there['0'].seat_class == "business")
      {
        query.class = 1;
      }
      else if (there['0'].seat_class == "first")
      {
        query.class = 2;
      }

      if (this.$route.query.tickets != '')
      {
        query.tickets = Number(this.$route.query.tickets);
      }

      this.$router.push({path: '/flight', query: query});
    },
    expandDetails() {
      this.dialog = true;
    }
  }
}

</script>


<style lang="scss">

.gold, .silver, .bronze {
  font-weight: bold;
  color: #fff;
  padding: 0.2em 0.4em;
  opacity: 0.8;
  border-radius: 5px;
}

.gold {
  background-color: #D6AF36;
}
.silver {
  background-color: #A7A7AD;
}
.bronze {
  background-color: #A77044;
}

.flight-result {
  margin-top: 1rem;
}

</style>

