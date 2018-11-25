<template>
  <div class='result'>
      <div> <span>From:</span> <br> {{ result.origin }}</div>
      <div> <span>To:</span> <br> {{ result.destination }}</div>
      <div class='price'>
        <button class='btn'>{{ result.price }} €</button>
      </div>
  </div>
</template>

<script>

export default {
  props: ['result'],
  created() {
    console.log(this.result);
  }
}

</script>


<style lang="scss" scoped>
  .result {
    width: 90%;
    background-color: #fff;
    padding: 1rem;
    display: flex;
    justify-content: row;
    margin: 0.2rem auto;

    div {
      flex-grow: 1;
      display: flex;
      justify-content: center;
      align-items: baseline;
      padding: 1em;
      font-size: 2em;
      border-right: 2px solid rgb(246, 246, 246);

      span {
        font-size: 1rem;
        font-weight: 200;
      }
    }

    .price {
      flex-grow: 1;
      display: flex;
      justify-content: center;
      align-items: center;
      font-weight: bold;
      font-size: 2em;
      border: none;
    }
  }
</style>

