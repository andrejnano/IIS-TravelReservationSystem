@php ($eva_host='/~xmarko15/')
<nav class="navbar navbar-expand-md navbar-dark bg-dark fixed-top">
  {{-- <a class="navbar-brand" href="#">Navbar</a> --}}
  <div class="container">
    <a class="navbar-brand" href="{{ url('/') }}">
        {{ config('app.name', 'IIS-projekt') }}
    </a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarsExampleDefault" aria-controls="navbarsExampleDefault" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
      <div class="collapse navbar-collapse" id="navbarsExampleDefault">
      <ul class="navbar-nav mr-auto">
        <li class="{{ Request::is('about') ? 'nav-item active' : 'nav-item' }}">
          <a class="nav-link" href={{$eva_host."about"}}>About</a>
        </li>
        @if(isset($is_admin) && $is_admin)
            <li class="{{ Request::is('manage_accounts') ? 'nav-item active' : 'nav-item' }}">
                <a class="nav-link" href={{$eva_host."manage_accounts"}}>Manage accounts</a>
            <li>
            <li class="{{ Request::is('manage_flights') ? 'nav-item active' : 'nav-item' }}">
                <a class="nav-link" href={{$eva_host."manage_flights"}}>Manage flights</a>
            <li>
        @endif
      </ul>
      <div class="pull-right">
      <ul class="navbar-nav mr-auto">
          <ul class="navbar-nav ml-auto">
              <!-- Authentication Links -->
              @guest
                  <li class="{{ Request::is('login') ? 'nav-item active' : 'nav-item' }}">
                      <a class="nav-link" href="{{ route('login') }}">{{ __('Login') }}</a>
                  </li>
                  <li class="{{ Request::is('register') ? 'nav-item active' : 'nav-item' }}">
                      @if (Route::has('register'))
                          <a class="nav-link" href="{{ route('register') }}">{{ __('Register') }}</a>
                      @endif
                  </li>
              @else
                  <li class="nav-item dropdown">
                      <a id="navbarDropdown" class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" v-pre>
                          {{ Auth::user()->name }} <span class="caret"></span>
                      </a>

                      <div class="dropdown-menu dropdown-menu-right" aria-labelledby="navbarDropdown">
                          <a class="dropdown-item" href="{{ route('logout') }}"
                             onclick="event.preventDefault();
                                           document.getElementById('logout-form').submit();">
                              {{ __('Logout') }}
                          </a>

                          <form id="logout-form" action="{{ route('logout') }}" method="POST" style="display: none;">
                              @csrf
                          </form>
                      </div>
                  </li>
              @endguest

        </ul>
      </div>
    </div>
  </div>
</nav>
  
