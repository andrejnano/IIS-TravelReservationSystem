@extends('layouts.app')
@section('content')
<?php
// print_r($request->all());
$request_arr = $args;

// $request_arr['origin']
// $request_arr['destination'
$results = DB::select('select city FROM airports', [1]);
$origin = $results[$request_arr['origin']]->{"city"};
$destination = $results[$request_arr['destination']]->{"city"};
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
?>
@endsection