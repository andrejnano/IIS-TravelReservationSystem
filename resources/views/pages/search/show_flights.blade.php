@extends('layouts.frame')
@section('content')
<?php
use Carbon\Carbon;

function set_location($location_key, $location_val) {
    $out = "
    ( $location_key.city = $location_val OR
        $location_key.country = $location_val OR
        $location_key.airport_code = $location_val )
    AND ";
    return $out;
}

function seat_filter($class, $number_of_tickets) {
    $out = "
    $class >= $number_of_tickets
    AND ";
    return $out;
}

$request_arr = $args;
$pdo = DB::connection()->getPdo();
$origin = $pdo->quote($request_arr['origin']);
$destination = $pdo->quote($request_arr['destination']);
$departure_before = $pdo->quote($request_arr['depart_before']);
$departure_after = $pdo->quote($request_arr['depart_after']);
$number_of_tickets = $pdo->quote($request_arr['tickets']);
$seat_class = $request_arr['class'];

if (!$departure_after)
    $departure_after = Carbon::now();
// todo change form
// ,	airport_code	city	country
$select_query = "
SELECT  flight_number, departure_time,	arrival_time,
        o.airport_code AS o_airport, o.city AS o_city, o.country AS o_country,
        d.airport_code AS d_airport, d.city AS d_city, d.country AS d_country
    FROM flights f, airports o, airports d
    WHERE
";
if ($request_arr['origin']) {
    $select_query .= set_location("o", $origin);
}
if ($request_arr['destination']) {
    $select_query .= set_location("d", $destination);
}
if ($request_arr['depart_before']) {
    $select_query .= " departure_time < $departure_before AND ";
}
if ($request_arr['depart_after']) {
    $select_query .= " departure_time > $departure_after AND ";
}
if ($request_arr['class']) {
    switch ($seat_class) {
        case "first":
            $select_query .= seat_filter("fclass_seats_free", $number_of_tickets);
            break;
        case "business":
            $select_query .= seat_filter("bclass_seats_free", $number_of_tickets);
            break;
        case "economy":
            $select_query .= seat_filter("eclass_seats_free", $number_of_tickets);
            break;
        }
} else {
    $select_query .= " (fclass_seats_free >= $number_of_tickets or bclass_seats_free >= $number_of_tickets or eclass_seats_free >= $number_of_tickets) AND ";
        
}

$select_query .= "f.origin = o.airport_code and f.destination = d.airport_code";
$results  = DB::select($select_query);

?>
@if (empty($results))
    <h1>No direct flight found from $origin to $destination</h1>";
@else
    <table>
        <tr>
            <th>Flight number</th>
            <th>Departure time</th>
            <th>Flight time</th>
            <th>Origin</th>
            <th>Destination</th>
        </tr>
@endif
<?php
    foreach($results as $r){
        echo "<tr>\n";
        // $value = $r['' => , ];
        $value = $r->flight_number;
        $flight = App\Flight::find($value);
        echo "<td><a href='".url("/flight/$flight->flight_number")."'>$value</a></td>\n";

        echo "<td>".date('Y-m-d G:i:s', strtotime($r->departure_time))."</td>\n";
        
        $flight_time = (strtotime($r->arrival_time) - strtotime($r->departure_time)) / 60;
        $flight_min = $flight_time % 60;
        $flight_hour = $flight_time / 60;
        // echo "<td>".$flight_chour."h ".$flighct_min."m</td>\n";
        printf("<td>%dh %dm</td>\n", $flight_hour, $flight_min);
        printf("<td>%s, %s, %s</td>", $r->o_airport, $r->o_city, $r->o_country);
        printf("<td>%s, %s, %s</td>", $r->d_airport, $r->d_city, $r->d_country);
        echo "</tr>\n";
    }
    
    ?>
    </table>
@endsection