<!doctype html>
<html lang="{{ app()->getLocale() }}">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, minimal-ui">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>{{config('app.name', 'IIS')}}</title>
    <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
    <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
    <link rel="manifest" href="/site.webmanifest">
    <link rel="mask-icon" href="/safari-pinned-tab.svg" color="#00FF9C">
    <meta name="msapplication-TileColor" content="#00FF9C">
    <meta name="theme-color" content="#00ff9c">
    <meta property="og:image" content="/og-image.jpg">
    <meta property="og:image:width" content="279">
    <meta property="og:image:height" content="279">
    <meta property="og:title" content="Flight Search">
    <meta property="og:description" content="Simple flight search engine created as a school project @ FIT, VUT Brno, Czech Republic">
  </head>
  <body>

    <!-- Vue will insert everything inside of this container -->
    <div id="app">
    </div>

    <script type="text/javascript" src="{{ mix('js/app.js') }}"></script>
  </body>
</html>
