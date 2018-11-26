<?php

namespace App\Http\Controllers\API;
use App\Mylibs\Common;
use Cookie;

use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class AdminController extends Controller
{
    /**
     * adds new flight into flight table. User must be admin
     */
    public function add_flight(Request $request)
    {
        if(!isset($_SESSION["user"])){
            abort(403, "Permission denied.");          
        }
        if($_SESSION["user"] != "admin"){
            abort(403, "Permission denied.");
        }
        if(!isset($request['flight_number']) ||
            !isset($request['airplane']) ||
            !isset($request['airline']) ||
            !isset($request['departure_time']) ||
            !isset($request['arrival_time']) ||
            !isset($request['origin']) ||
            !isset($request['destination']) ) {
            abort(400, "Missing argument. Can not add this flight.");
        }
        try {
            DB::table('flights')->insert(
                ['flight_number' => $request['flight_number'],
                "departure_time" => $request['departure_time'],
                "arrival_time" => $request['arrival_time'],
                "airplane" => $request['airplane'],
                "airline" => $request['airline'],
                "origin" => $request['origin'],
                "destination" => $request['destination']]
            );
        } catch (Exception $e) {
            abort(500, "Error in inserting flight into database.");
        }
        return 'Flight made >';
    }
}