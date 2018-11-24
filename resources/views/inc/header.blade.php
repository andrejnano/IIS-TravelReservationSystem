<header id="app">
  @include('inc.navigation')
  {{-- <span class='text--lg'>header</span><br> --}}
  {{ Form::open(array('url' => '/api/search/', 'method' => 'GET', 'class' => 'form-wrap')) }}
    <div>
      <div class='text-field text-field--white'>
        <font-awesome-icon icon="plane-departure"></font-awesome-icon>
        <input type="text" name="origin" id='primary-input' class='text-field__input' value="{{ (isset($args)) ? $args['origin'] : ''}}">
        <label for='primary-input' class='text-field__label'>Departure:</label>
      </div>
      <div class='text-field text-field--white'>
        <font-awesome-icon icon="plane-arrival"></font-awesome-icon>
        <input type="text" name="destination" id='secondary-input' class='text-field__input' value="{{ (isset($args)) ? $args['destination'] : ''}}">
        <label for='secondary-input' class='text-field__label'>Arrival:</label>
      </div>
    </div>
    <div class='text-field text-field--white'>
      <font-awesome-icon icon="plane-arrival"></font-awesome-icon>
      <input type='text' id='secondary-input' class='text-field__input'>
      <label for='secondary-input' class='text-field__label'>Arrival:</label>
    </div>
    <button class='btn'>Search</button>
  </form>
</header>
