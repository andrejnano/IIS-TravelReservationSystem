<script>
import Navigation from './components/Navigation.vue';

export default {
  components: {
    'navigation': Navigation
  }
}
</script>

<template>
  <div id="app">

    <navigation></navigation>

    <transition name="fade" mode="out-in">
      <router-view></router-view>
    </transition>

  </div>
</template>


<style lang="scss" scoped>

  .fade-enter-active, .fade-leave-active {
    transition: all .2s ease;
  }
  .fade-enter, .fade-leave-active {
    opacity: 0;
  }

</style>

