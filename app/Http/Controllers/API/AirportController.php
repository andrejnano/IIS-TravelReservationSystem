<?php

namespace App\Http\Controllers\API;
use App\Mylibs\Common;
use Cookie;

use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class AirportController extends Controller
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
}
