
<template>
  <div>
    <v-list-tile avatar @click="expandDetails" slot="activator" ripple>
      <v-list-tile-avatar>
        <img :src="logo">
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
          class="headline grey lighten-2"
          primary-title
          v-html="expandedTitle"
        >
        </v-card-title>

        <v-card-text>
          {{ expandedBody }}
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions>
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

    logo: function() {
      return `../images/${this.result.there['0'].airline.id_logo}.png`;
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

    expandedBody: function() {
        return "body";
    }

  },
  methods: {
    close () {
      this.dialog = false;
    },
    openFlight() {

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

      query.class = there.seat_class;
      query.tickets = 1;

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
  opacity: 0.5;
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

