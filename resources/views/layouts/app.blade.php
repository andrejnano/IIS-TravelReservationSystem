<!doctype html>
<html lang="{{ config('app.locale') }}">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        {{-- css not working; npm install fails --}}
        <link rel="stylesheet" href="{{ asset('sass/app.scss') }}" type="text/css">
        <title>{{config('app.name', 'IIS')}}</title>
        {{-- <title>42</title> --}}

    </head>
    <body class="navbar-laravel">
        <ul>
            <li><a href="/booking">BOOKING</a></li>
            <li><a href="/promotional">PROMOTIONAL OFFERS</a></li>
            <li><a href="/timetables">TIMETABLES AND STOPS</a></li>
            <li><a href="/prices">PRICES AND TICKETS</a></li>
            <li><a href="/about">ABOUT</a></li>
            <li><a href="/map">MAP OF LINES</a></li>
        </ul>
        <li><a href="/login">login or create account</a></li>
        @yield('content')
    </body>
</html>
