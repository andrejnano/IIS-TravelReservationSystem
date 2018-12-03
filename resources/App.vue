<script>
/*
 THIS IS THE ROOT COMPONENT OF THE WHOLE CLIENT SIDE APP
*/

import Navigation from './components/Navigation.vue';
import WebFontLoader from 'webfontloader'; // for asynchronous font loading

export default {
  components: {
    'navigation': Navigation
  },
  mounted () {
    WebFontLoader.load({
      google: {
        families: ['Ubuntu:300,400,700']
      },
      active: this.setFontLoaded
    })
  },
  methods: {
    setFontLoaded () {
      this.$emit('font-loaded')
    }
  }
}
</script>

<template>
  <v-app id="app" dark>

    <navigation></navigation>

    <transition name="fade" mode="out-in">
      <router-view></router-view>
    </transition>

    <v-footer color="primary darken-2">
      <v-container fluid pa-1>
        <v-layout row justify-start>
          <v-flex xs6 class="text-white">
            &copy; {{ new Date().getFullYear() }} —  <strong> &nbsp; Flight Reservation System</strong>&nbsp; @ FIT VUT, Brno
          </v-flex>
        </v-layout>
      </v-container>
    </v-footer>
  </v-app>
</template>


<style lang="scss" scoped>

  .fade-enter-active, .fade-leave-active {
    transition: all .2s ease;
  }
  .fade-enter, .fade-leave-active {
    opacity: 0;
  }

</style>

