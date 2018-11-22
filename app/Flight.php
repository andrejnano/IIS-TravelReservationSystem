<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Flight extends Model
{
    //
    // protected $table = 'my_flights';
    protected $primaryKey = 'flight_number';
    public $incrementing = false;
    public $timestamps = false;
}