<!doctype html>
<html lang="{{ config('app.locale') }}">
  <head>
    @include('inc.doc_head')
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
