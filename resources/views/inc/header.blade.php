<header id="app">
  @include('inc.navigation')
  {{-- <span class='text--lg'>header</span><br> --}}
  {{ Form::open(array('url' => 'search/form', 'method' => 'GET', 'class' => 'form-wrap')) }}
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
    <div>
      <div class='text-field text-field--white'>
          <input type="text" name="depart_after" id='primary-input' class='text-field__input' value="{{ (isset($args)) ? $args['depart_after'] : ''}}">
          <label for='primary-input' class='text-field__label'>Departure after:</label>
      </div>
      <div class='text-field text-field--white'>
          <input type="text" name="depart_before" id='primary-input' class='text-field__input' value="{{ (isset($args)) ? $args['depart_before'] : ''}}">
          <label for='primary-input' class='text-field__label'>Departure before:</label>
      </div>
    </div>
    <div>
      <div class='text-field text-field--white'>
        <label for='tickets' class='text-field__label'>Number of tickets:</label>
        {{ Form::number('tickets', $value=(isset($args)) ? $args['tickets'] : "1", ['min' => '1' ,'class' => 'text-field__input', 'id' => 'tickets','required']) }}
      </div>

      <div class='text-field text-field--white'>
        <label for='class' class='text-field__label'>Seat class:</label>
          <select name="class" class='text-field__input'>
            <option {{ isset($args) && $args['class'] == '' ? "selected" : ""}} value=""></option>
            <option {{ isset($args) && $args['class'] == 'first' ? "selected" : ""}} value="first">first</option>
            <option {{ isset($args) && $args['class'] == 'business' ? "selected" : ""}} value="business">business</option>
            <option {{ isset($args) && $args['class'] == 'economy' ? "selected" : ""}} value="economy">economy</option>
          </select>
        {{-- {{ Form::select('class', array_merge(['' => 'first'], ['', 'first', 'business', 'economy']), null, ['class' => 'text-field__input']) }} --}}
      </div>
    </div>
    <button class='btn'>Search</button>
  </form>
</header>
