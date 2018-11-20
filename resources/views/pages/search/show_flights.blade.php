@extends('layouts.app')
@section('content')
<?php
$request_arr = $args;
// print_r($request_arr);

// $request_arr['origin']
// $request_arr['destination'
$results = DB::select('select city FROM airports', [1]);
$origin = $request_arr['origin'];
$destination = $request_arr['destination'];
$results  = DB::select(
"SELECT flights.flight_number , flights.departure_time, flights.arrival_time
FROM flights 
WHERE flights.origin IN (
  SELECT airport_code FROM airports WHERE airports.city = '$origin'
) 
AND flights.destination IN (
  SELECT airport_code FROM airports WHERE airports.city = '$destination');");
if (!sizeof($results)) {
    return "No direct flight found";
}
echo "<table>\n";
echo "<tr>\n";
foreach($results[0] as $key=>$value) {
    echo "<th>".$key."</th>\n";
}
echo "</tr>\n";
foreach($results as $r){
    // echo "result".$r;
    echo "<tr>\n";
    foreach($r as $key=>$value) {
        echo "<td>".$value."</td>\n";
    }
    echo "</tr>\n";
}
echo "</table>\n";
?>
@endsection