<template>
  <v-list-tile avatar @click="expandDetails" ripple>
    <v-list-tile-avatar>
      <img :src="logo">
    </v-list-tile-avatar>
    <v-list-tile-content>
      <v-list-tile-title> {{ thereTitle }} </v-list-tile-title>
      <v-list-tile-sub-title v-html="subTitle"></v-list-tile-sub-title>
    </v-list-tile-content>
    <v-spacer></v-spacer>
    <v-btn @click="openFlight" dark color="green" large>
      {{ result.total_price }} €
    </v-btn>
  </v-list-tile>
</template>

<script>

export default {
  props: ['result'],
  data: () => ({
    show: false,
  }),
  created() {
    console.log("got a result");
    console.log({result: this.result})
  },
  computed: {
    subTitle: function() {
      var output = "";

      const isRoundTrip = this.result.hasOwnProperty('back');

      output += this.thereDetailedTitle;

      if (isRoundTrip) {
        output += " <br>" + this.backDetailedTitle;
      }
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

      output += "<br>Class: " + classString;

      output += " | <span class='mdi mdi-timer'></span><strong>" + this.result.total_time + " hours</strong>";

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

      var output = "";
      var there = this.result.there;

      const isConnectingThere = this.result.there.hasOwnProperty('1');

      output += there['0'].origin.airport + " <strong>" + there['0'].departure_time + "</strong> → ";

      if (isConnectingThere)
      {
        output += there['1'].origin.airport + " <strong>" + there['1'].departure_time + "</strong> (stop) → ";
        output += there['1'].destination.airport + " " + there['1'].arrival_time;
      }
      else
      {
        output += there['0'].destination.airport + " <strong>" + there['0'].arrival_time + "</strong>";
      }

      return output;
    },
    backDetailedTitle: function() {
      var output = "";
      var back = this.result.back;

      const isConnectingBack= this.result.back.hasOwnProperty('1');

      output += back['0'].origin.airport + "  <strong>" + back['0'].departure_time + "</strong> → ";

      if (isConnectingBack)
      {
        output += back['1'].origin.airport + " <strong>" + back['1'].departure_time + "</strong> (stop) → ";
        output += back['1'].destination.airport + " <strong>" + back['1'].arrival_time + "</strong>";
      }
      else
      {
        output += back['0'].destination.airport + " <strong>" + back['0'].arrival_time + "</strong>";
      }

      return output;
    },

    logo: function() {
      return `../images/${this.result.there['0'].airline.id_logo}.png`;
    }
  },
  methods: {
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

