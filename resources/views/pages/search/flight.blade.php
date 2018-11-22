@extends('layouts.frame')
@section('content')
<ul>
    <li>departure_time: {{date('Y-m-d G:i:s', strtotime($flight->departure_time))}}</li>
    <li>arrival_time: {{date('Y-m-d G:i:s', strtotime($flight->arrival_time))}}</li>
    <li>airplane: 
        <?php
            $airplane = DB::table('airplanes')->WHERE('id','=', $flight->airplane)->first();
            printf("%s %s", $airplane->producer, $airplane->model);
        ?>
    </li>
    <li>airline:
        <?php
            $airline = DB::table('airlines')->WHERE('airline','=', $flight->airline)->first();
            printf("%s, %s", $airline->full_name, $airline->nationality);
        ?>
    </li>
    <li>origin:
        <?php
            $airport = DB::table('airports')->WHERE('airport_code','=', $flight->origin)->first();
            printf("%s, %s", $airport->city, $airport->country);
        ?>
    </li>
    <li>destination:
        <?php
            $airport = DB::table('airports')->WHERE('airport_code','=', $flight->destination)->first();
            printf("%s, %s", $airport->city, $airport->country);
        ?>
    </li>
    {{Form::open(array('url' => "/flight/$flight->flight_number/reserve"))}}
    {{Form::submit( 'Make reservation', ['name' => 'reservation', 'class' => 'btn'])}} 
    {{Form::close()}}
<ul>
@endsection