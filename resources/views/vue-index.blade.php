<!doctype html>
<html lang="{{ app()->getLocale() }}">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, minimal-ui">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>{{config('app.name', 'IIS')}}</title>
  </head>
  <body>
    
    <!-- Vue will insert everything inside of this container -->
    <div id="app">
    </div>

    <script type="text/javascript" src="{{ mix('js/app.js') }}"></script>
  </body>
</html>
