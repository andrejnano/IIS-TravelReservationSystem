@php ($eva_host='/~xmarko15/')
<nav class="navbar navbar-expand-md navbar-dark bg-dark fixed-top">
  {{-- <a class="navbar-brand" href="#">Navbar</a> --}}
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarsExampleDefault" aria-controls="navbarsExampleDefault" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
    <div class="collapse navbar-collapse" id="navbarsExampleDefault">
    <ul class="navbar-nav mr-auto">
      <li class="{{ Request::is('booking') ? 'nav-item active' : 'nav-item' }}">
        <a class="nav-link" href={{$eva_host."booking"}}>Booking</a>
      </li>
      <li class="{{ Request::is('promotional') ? 'nav-item active' : 'nav-item' }}">
        <a class="nav-link" href="/promotional">Promotional offers</a>
      </li>
      <li class="{{ Request::is('timetables') ? 'nav-item active' : 'nav-item' }}">
        <a class="nav-link" href="/timetables">Timetables</a>
      </li>
      <li class="{{ Request::is('prices') ? 'nav-item active' : 'nav-item' }}">
        <a class="nav-link" href="/prices">Prices and tickets</a>
      </li>
      <li class="{{ Request::is('about') ? 'nav-item active' : 'nav-item' }}">
        <a class="nav-link" href={{$eva_host."about"}}>About</a>
      </li>
    </ul>
    <form class="form-inline my-2 my-lg-0">
      <input class="form-control mr-sm-2" type="text" placeholder="Search" aria-label="Search">
      <button class="btn btn-outline-success my-2 my-sm-0" type="submit">Search</button>
    </form>
  </div>
</nav>
  
