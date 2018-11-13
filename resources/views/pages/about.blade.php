@extends('layouts.app')
@section('content')
  <h1>Flights</h1>
  <span class='subtitle'>View of all the flights in the DB</span> <br>
  <table>
    <?php
    $results = DB::select('select * FROM flights', [1]);

    echo "<tr>\n";
    foreach($results[0] as $key=>$value) {  echo "<th>".$key."</th>\n"; }
    echo "</tr>\n";
    foreach($results as $r)
    {
      echo "<tr>\n";
      foreach($r as $key=>$value) { echo "<td>".$value."</td>\n"; }
      echo "</tr>\n";
    }
    ?>
  </table>
@endsection
