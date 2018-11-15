<!doctype html>
<html lang="{{ config('app.locale') }}">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
    <link rel="stylesheet" href="{{ asset('css/style.css') }}?<?php echo time(); ?>" type="text/css"  media="all">
    <title>{{config('app.name', 'IIS')}}</title>
  </head>
  <body class='webpage'>
    @include('inc.header')
    @include('inc.sidebar')
    <main>
      @yield('content')
    </main>
    @include('inc.footer')

    <script src="{{ asset('js/app.js') }}"></script>
  </body>
</html>
