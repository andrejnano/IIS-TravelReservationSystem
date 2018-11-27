<template>
  <div class='result'>
      <div> {{ result.origin.airport }} </div>
      <div> {{ result.destination.airport }} </div>
      <div class='price'>
        <button class='btn'>{{ result.price }} €</button>
      </div>
  </div>
</template>

<script>

export default {
  props: ['result'],
  created() {
    console.log("got a result");
  }
}

</script>


<style lang="scss" scoped>

</style>

