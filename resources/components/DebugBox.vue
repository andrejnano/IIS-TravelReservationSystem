<template>
  <div class='floating-box'>
    <table class='inner-table'>
      <tr v-for='item in input' v-bind:key="item.name">
        <td>{{item.name}}: </td>
        <td>{{item.value}}</td>
      </tr>
    </table>
  </div>
</template>

<script>
export default {
  props: {
    input: {
      Type: Array,
      required: true
    }
  }
}
</script>

<style lang="scss" scoped>

.floating-box {
  background: #fff;
  width: 300px;
  text-align: left;
  font-family: monospace;
  font-size: 11px;
  position: fixed;
  bottom: 0;
  right: 0;
  padding: 1rem;

  .inner-table {
    width: 100%;

    tr > td:first-child {
      font-weight: bold;
      text-align: right;
    }
  }
}

</style>
