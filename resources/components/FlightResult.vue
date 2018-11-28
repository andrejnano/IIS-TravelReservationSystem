<template>
  <v-list-tile avatar @click="">
    <v-list-tile-avatar>
      <img :src="logo">
    </v-list-tile-avatar>
    <v-list-tile-content>
      <v-list-tile-title v-html="title"></v-list-tile-title>
      <v-list-tile-sub-title>Flight number: {{result.flight_number}}</v-list-tile-sub-title>
      <!-- <v-btn dark color="primary" large>
        {{ result.price }} €
      </v-btn> -->
    </v-list-tile-content>
    <v-spacer></v-spacer>
    <v-btn dark color="primary" large>
      {{ result.price }} €
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
    title: function() {
      return this.result.origin.airport + " → " + this.result.destination.airport;
    },

    logo: function() {
      return `../images/${this.result.airline.id_logo}.png`;
    }

  }
}

</script>


<style lang="scss" scoped>


.flight-result {
  margin-top: 1rem;
}

</style>

