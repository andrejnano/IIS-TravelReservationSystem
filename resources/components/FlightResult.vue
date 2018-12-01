<template>
  <v-list-tile avatar>
    <v-list-tile-avatar>
      <img :src="logo">
    </v-list-tile-avatar>
    <v-list-tile-content>
      <v-list-tile-title v-html="title">{{ thereTitle }}</v-list-tile-title>
      <v-list-tile-sub-title>Flight number (there): {{result.there['0'].flight_number}} | Total time: {{result.total_time}}</v-list-tile-sub-title>
    </v-list-tile-content>
    <v-spacer></v-spacer>
    <v-btn @click="openFlight" dark color="primary" large>
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
  },
  computed: {
    thereTitle: function() {
      var output;
      if (this.there.hasOwnProperty('1')) {
        // s prestupom
        output += this.there['0'].origin.city + " → ";
        output += this.there['1'].destination.city;
      } else {
        // bez prestupu
        output += this.there['0'].origin.city + " → ";
        output += this.there['0'].destination.city;
      }
      return output;
    },
    backTitle: function() {
      var output;
      if (this.there.hasOwnProperty('1')) {
        // s prestupom
        output += this.there['0'].origin.city + " → ";
        output += this.there['1'].destination.city;
      } else {
        // bez prestupu
        output += this.there['0'].origin.city + " → ";
        output += this.there['0'].destination.city;
      }
      return output;
    },
    thereDetailedTitle: function() {
      var output;
      if (this.there.hasOwnProperty('1')) {
        // s prestupom
        output += this.there['0'].origin.city + " → ";
        output += this.there['0'].destination.city + " → ";
        output += this.there['1'].destination.city;
      } else {
        // bez prestupu
        output += this.there['0'].origin.city + " → ";
        output += this.there['0'].destination.city;
      }
      return output;
    },
    backDetailedTitle: function() {
      var output;
      if (this.back.hasOwnProperty('1')) {
        // s prestupom
        output += this.back['0'].origin.city + " → ";
        output += this.back['0'].destination.city + " → ";
        output += this.back['1'].destination.city;
      } else {
        // bez prestupu
        output += this.back['0'].origin.city + " → ";
        output += this.back['0'].destination.city;
      }
      return output;
    },

    logo: function() {
      return `../images/${this.result.airline.id_logo}.png`;
    }
  },
  methods: {
    openFlight() {
      this.$router.push({
        path: '/flight',
        query: {
          flight_number: this.result.flight_number
        }
      });
    }
  }
}

</script>


<style lang="scss" scoped>


.flight-result {
  margin-top: 1rem;
}

</style>

