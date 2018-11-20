<!doctype html>
<html lang="{{ config('app.locale') }}">
  <head>
    @include('inc.doc_head')
  </head>
  <body class='webpage'>
    @include('inc.navigation')
    <main>
      @yield('content')
    <main>
    <script src="{{ asset('js/app.js') }}"></script>
  </body> 
</html>