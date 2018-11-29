<?php

namespace App\Http\Controllers\API;
use App\Mylibs\Common;
use Cookie;

use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class GetTableController extends Controller
{
    /**
     * Create new session and set $_SESSION super-global log in variables
     *
     * @param Request User request
     * @return void
     */
    public function get_airports() {
        $airports = DB::table('airports')->get();

        $airport_arr = array();
        foreach ($airports as $airport) {
            array_push($airport_arr, $airport);
        }
        return json_encode($airport_arr);
    }

    public function get_flights () {
        $flights = DB::table('flights')->get();

        $flight_arr = array();
        foreach ($flights as $flight) {
            array_push($flight_arr, $flight);
        }
        return json_encode($flight_arr);
    }
    public function get_airplanes () {
        $airplanes = DB::table('airplanes')->get();

        $airplane_arr = array();
        foreach ($airplanes as $airplane) {
            array_push($airplane_arr, $airplane);
        }
        return json_encode($airplane_arr);
    }
    public function get_airlines () {
        $airlines = DB::table('airlines')->get();

        $airline_arr = array();
        foreach ($airlines as $airline) {
            array_push($airline_arr, $airline);
        }
        return json_encode($airline_arr);

    }


}
