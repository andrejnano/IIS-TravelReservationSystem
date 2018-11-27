<?php

namespace App\Http\Controllers\API;
use App\Mylibs\Common;
use Cookie;

use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use App\Http\Controllers\API\UserController;

class AdminController extends Controller
{
    /**
     * adds new flight into flight table. User must be admin
     */
    public function add_flight(Request $request)
    {
        if (!UserController::logged_in())
            abort(403, "Permission denied.");
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
    }

    /**
     * updates data in users database. Request must be send by admin or updated user.
     */
    public function update_user(Request $request)
    {
        if(!isset($request['id'])){
            abort(400, "Missing user id.");
        }
        if(!UserController::logged_in()){
            abort(403, "Permission denied.");          
        }
        if($_SESSION["user"] != "admin" && $_SESSION["uid"] != $request['id']){
            abort(403, "Permission denied.");          
        }
        try{
            if(isset($request['first_name'])){
                DB::table('users')->where('id', $request['id'])->update(['first_name' => $request['first_name']]);
            }
            if(isset($request['last_name'])){
                DB::table('users')->where('id', $request['id'])->update(['last_name' => $request['last_name']]);
            }
            if(isset($request['email'])){
                DB::table('users')->where('id', $request['id'])->update(['email' => $request['email']]);
            }
            if(isset($request['password'])){
                DB::table('users')->where('id', $request['id'])->update(['password' => $request['password']]);
            }
            if(isset($request['is_admin']) && $_SESSION["user"] == "admin"){
                DB::table('users')->where('id', $request['id'])->update(['is_admin' => $request['is_admin']]);
            }
        } catch (Exception $e) {
            abort(500, "Error in updating users database.");
        }
    }

    /**
     * Deletes user from database. Must be send by admin.
     */
    public function delete_user(Request $request)
    {
        if(!isset($request['id'])){
            abort(400, "Missing user id.");
        }
        if(!UserController::logged_in()){
            abort(403, "Permission denied.");          
        }
        if($_SESSION["user"] != "admin"){
            abort(403, "Permission denied.");          
        }
        try {
            DB::table('users')->where('id', $request['id'])->delete();
        } catch (Exception $e) {
            abort(500, "Error in deleting user from database.");
        }
        return "deleted";
    }
}