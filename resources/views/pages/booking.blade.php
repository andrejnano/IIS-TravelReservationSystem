@extends('layouts.app')
@section('content')
    <h1>Booking</h1>
    <?php
    
    $results = DB::select('select city, country FROM airports', [1]);
    $combo = array();
    foreach($results as $r){
        array_push($combo, $r->{"city"}.": ".$r->{"country"});
    }
    echo '<label for="origin">Origin: </label>';
    echo Form::select('origin', $combo, null, ['class' => 'blabla']);
    echo '<label for="destination">Destination: </label>';
    echo Form::select('destination', $combo, null, ['class' => 'blabla']);
    echo '<br>';
    echo Form::submit("OK");
    ?>
@endsection 