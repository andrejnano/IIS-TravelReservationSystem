<!doctype html>
<html lang="{{ config('app.locale') }}">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        {{-- css not working; npm install fails --}}
        <link rel="stylesheet" href="{{ asset('css/app.css') }}" type="text/css">
        <title>{{config('app.name', 'IIS')}}</title>
        {{-- <title>42</title> --}}

        @include('inc.navbar')
    </head>
    <body class="navbar-laravel">
        @yield('content')
    </body>
</html>
