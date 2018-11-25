
@extends('layouts.blank')

@section('content')
  <h1>Loginnnnn</h1>
  <?php

    echo Form::open(array('url' => '/api/login', 'method' => 'POST'));
        echo Form::label('email', 'Email Address');
        echo Form::text('email');
        echo Form::label('password', 'Password');
        echo Form::password('password');
        echo Form::submit("OK");
    echo Form::close();
    ?>
    <h1>Sign up</h1>
    <?php
    echo Form::open(array('url' => 'login', 'method' => 'POST'));
        echo Form::text('first_name', '', ['placeholder' => 'First name']);
        echo Form::text('last_name', '', ['placeholder' => 'Last name']);
        echo "</br>";
        echo Form::text('email', '', ['placeholder' => 'Email']);
        echo "</br>";
        echo Form::password('password', ['placeholder' => 'Paswoord']);
        echo "</br>";
        echo Form::submit("OK");
    echo Form::close();
  ?>
@endsection
