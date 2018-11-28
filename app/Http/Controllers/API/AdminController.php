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
        if(!$request->input('flight_number') ||
            !$request->input('airplane') ||
            !$request->input('airline') ||
            !$request->input('departure_time') ||
            !$request->input('arrival_time') ||
            !$request->input('origin') ||
            !$request->input('destination') ) {
            abort(400, "Missing argument. Can not add this flight.");
        }
        try {
            DB::table('flights')->insert(
                ['flight_number' => $request->input('flight_number'),
                "departure_time" => $request->input('departure_time'),
                "arrival_time" => $request->input('arrival_time'),
                "airplane" => $request->input('airplane'),
                "airline" => $request->input('airline'),
                "origin" => $request->input('origin'),
                "destination" => $request->input('destination')]
            );
        } catch (Exception $e) {
            abort(500, "Error in inserting flight into database.");
        }
    }

    /**
     * adds new airline into airlines table. User must be admin
     */
    public function add_airline(Request $request)
    {
        if (!UserController::logged_in())
            abort(403, "Permission denied.");
        if($_SESSION["user"] != "admin"){
            abort(403, "Permission denied.");
        }
        if(!$request->input('airline') ||
            !$request->input('full_name') ||
            !$request->input('nationality') ||
            !$request->input('hub') ) {
            abort(400, "Missing argument. Can not add this airline.");
        }
        try {
            DB::table('airlines')->insert(
                ["airline" => $request->input('airline'),
                "full_name" => $request->input('full_name'),
                "nationality" => $request->input('nationality'),
                "hub" => $request->input('hub')]
            );
            if($request->input('id_logo')){
                DB::table('airlines')->where('airline', $request->input('airline'))->update(['id_logo' => $request->input('id_logo')]);
            }
        } catch (Exception $e) {
            abort(500, "Error in inserting airline into database.");
        }
    }

    /**
     * adds new airport into airports table. User must be admin
     */
    public function add_airport(Request $request)
    {
        if (!UserController::logged_in())
            abort(403, "Permission denied.");
        if($_SESSION["user"] != "admin"){
            abort(403, "Permission denied.");
        }
        if(!$request->input('airport_code') ||
            !$request->input('city') ||
            !$request->input('country') ) {
            abort(400, "Missing argument. Can not add this airline.");
        }
        try {
            DB::table('airports')->insert(
                ["airport_code" => $request->input('airport_code'),
                "city" => $request->input('city'),
                "country" => $request->input('country')]
            );
        } catch (Exception $e) {
            abort(500, "Error in inserting airport into database.");
        }
    }

    /**
     * adds new airplane into airplanes table. User must be admin
     */
    public function add_airplane(Request $request)
    {
        if (!UserController::logged_in())
            abort(403, "Permission denied.");
        if($_SESSION["user"] != "admin"){
            abort(403, "Permission denied.");
        }
        if(!$request->input('producer') ||
            !$request->input('model') ||
            !$request->input('fclass_seats') ||
            !$request->input('bclass_seats') ||
            !$request->input('eclass_seats') ||
            !$request->input('airline') ) {
            abort(400, "Missing argument. Can not add this airplane.");
        }
        try {
            DB::table('airplanes')->insert(
                ["producer" => $request->input('producer'),
                "model" => $request->input('model'),
                "fclass_seats" => $request->input('fclass_seats'),
                "bclass_seats" => $request->input('bclass_seats'),
                "eclass_seats" => $request->input('eclass_seats'),
                "airline" => $request->input('airline')]
            );
        } catch (Exception $e) {
            abort(500, "Error in inserting airplane into database.");
        }
    }

    /**
     * updates data in users database. Request must be send by admin or updated user.
     */
    public function update_user(Request $request)
    {
        if(!$request->input('id')){
            abort(400, "Missing user id.");
        }
        if(!UserController::logged_in()){
            abort(403, "Permission denied.");          
        }
        if($_SESSION["user"] != "admin" && $_SESSION["uid"] != $request->input('id')){
            abort(403, "Permission denied.");          
        }
        try{
            if($request->input('first_name')){
                DB::table('users')->where('id', $request->input('id'))->update(['first_name' => $request->input('first_name')]);
            }
            if($request->input('last_name')){
                DB::table('users')->where('id', $request->input('id'))->update(['last_name' => $request->input('last_name')]);
            }
            if($request->input('email')){
                DB::table('users')->where('id', $request->input('id'))->update(['email' => $request->input('email')]);
            }
            if($request->input('password')){
                DB::table('users')->where('id', $request->input('id'))->update(['password' => $request->input('password')]);
            }
            if($request->input('is_admin') && $_SESSION["user"] == "admin"){
                DB::table('users')->where('id', $request->input('id'))->update(['is_admin' => $request->input('is_admin')]);
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
        if(!$request->input('id')){
            abort(400, "Missing user id.");
        }
        if(!UserController::logged_in()){
            abort(403, "Permission denied.");          
        }
        if($_SESSION["user"] != "admin"){
            abort(403, "Permission denied.");          
        }
        try {
            DB::table('users')->where('id', $request->input('id'))->delete();
        } catch (Exception $e) {
            abort(500, "Error in deleting user from database.");
        }
        return "deleted";
    }

    // todo
    /* public function delete_airline(Request $request) {

    }

    public function delete_airplane(Request $request) {

    }

    public function delete_flight(Request $request) {

    } */
}