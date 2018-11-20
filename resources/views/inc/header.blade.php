<header id="app">
  @include('inc.navigation')
  <span class='text--lg'>header</span><br>
  <?php
  echo Form::open(array('url' => 'search/form', 'method' => 'GET', 'class' => 'form-wrap'));
    ?>
    <div class='text-field text-field--white'>
      <font-awesome-icon icon="plane-departure"></font-awesome-icon>
      <input type='text' name='origin' id='primary-input' class='text-field__input'>
      <label for='primary-input' class='text-field__label'>Departure:</label>
    </div>a
    <div class='text-field text-field--white'>
      <font-awesome-icon icon="plane-arrival"></font-awesome-icon>
      <input type='text' name='destination' id='secondary-input' class='text-field__input'>
      <label for='secondary-input' class='text-field__label'>Arrival:</label>
    </div>
    <button class='btn'>Search</button>
  </form>
</header>
