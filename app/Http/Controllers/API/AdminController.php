<?php

namespace App\Http\Controllers\API;
use App\Mylibs\Common;
use Cookie;

use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use App\Http\Controllers\API\UserController;
use Illuminate\Support\Facades\Hash;

class AdminController extends Controller
{
    protected function abort_if_no_admin() {
        $no_permission_msg = "Permission denied.";
        if (!UserController::logged_in())
            abort(403, $no_permission_msg);
        if($_SESSION["user"] != "admin"){
            abort(403, $no_permission_msg);
        }
    }
    /**
     * adds new flight into flight table. User must be admin
     */
    public function add_flight(Request $request)
    {
        $this->abort_if_no_admin();
        if(
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
                ["departure_time" => $request->input('departure_time'),
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
        $this->abort_if_no_admin();
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
        $this->abort_if_no_admin();
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
        $this->abort_if_no_admin();
        if(!$request->input('producer') ||
            !$request->input('model') ||
            (!$request->input('fclass_seats') && $request->input('fclass_seats') !== "0") ||
            (!$request->input('bclass_seats') && $request->input('bclass_seats') !== "0") ||
            (!$request->input('eclass_seats') && $request->input('eclass_seats') !== "0") ||
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
     * function adds new user into database. Only for admin.
     */
    public function add_user(Request $request) {
        $this->abort_if_no_admin();
        if (!$request->input('first_name') || !$request->input('last_name') ||
        !$request->input('email') || !$request->input('password')) {
            abort(400, 'Parameter from first_name, last_name, email, password is missing');
        }
        $user = DB::table('users')->where('email', '=', $request->input('email'))->first();
        if ($user) {
            abort(409, 'User already registered');
        }
        else {
            try {
                DB::table('users')->insert([
                    "first_name" => $request->input("first_name"),
                    "last_name" => $request->input("last_name"),
                    "email" => $request->input("email"),
                    "password" => Hash::make($request->input("password"))
                    ]);
            } catch (Exception $e) {
                abort(500);
            }
        }
    }

    /**
     * updates data in airlines database. Request must be send by admin.
     */
    public function update_airline(Request $request)
    {
        if(!$request->input('airline')){
            abort(400, "Missing airline identification.");
        }
        $this->abort_if_no_admin();
        try{
            if($request->input('full_name')){
                DB::table('airlines')->where('airline', $request->input('airline'))->update(['full_name' => $request->input('full_name')]);
            }
            if($request->input('nationality')){
                DB::table('airlines')->where('airline', $request->input('airline'))->update(['nationality' => $request->input('nationality')]);
            }
            if($request->input('hub')){
                DB::table('airlines')->where('airline', $request->input('airline'))->update(['hub' => $request->input('hub')]);
            }
            if($request->input('id_logo')){
                DB::table('airlines')->where('airline', $request->input('airline'))->update(['id_logo' => $request->input('id_logo')]);
            }
        } catch (Exception $e) {
            abort(500, "Error in updating airlines database.");
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

    /**
     * Removes flight and all its dependencies from database
     */
    protected function delete_flight($flight_number) {
        DB::table('tickets')->where('flight', $flight_number)->delete();
        $deleted = DB::table('flights')->where('flight_number', $flight_number)->delete();
        if (!$deleted) {
            abort(400, 'Not found rows for delete in table flights');
        }
    }


    /**
     * Parses input parameters and checks if admin logged, then remove flight from DB
     */
    public function user_delete_flight(Request $request) {
        $this->abort_if_no_admin();
        if(!$request->input('flight_number'))
            abort(400, "Missing flight id.");
        $this->delete_flight($request->input('flight_number'));
    }
    
    /**
     * Removes airplane from DB and all it's dependencies
     */
    protected function delete_airplane($airplane_id) {
        $flights = DB::table('flights')->where('airplane', '=', $airplane_id)->get();
        foreach($flights as $flight) {
            $this->delete_flight($flight->flight_number);
        }
        $deleted = DB::table('airplanes')->where('id', $airplane_id)->delete();
        if (!$deleted)
            abort(400, 'Not found rows for delete in table airplanes');
    }

    /**
     * Parses input parameters and checks if admin logged, then remove airplane from DB
     */
    public function user_delete_airplane(Request $request) {
        $this->abort_if_no_admin();
        if(!$request->input('airplane'))
            abort(400, "Missing airplane id.");
        
        $this->delete_airplane($request->input('airplane'));
    }

    /**
     * Parses input parameters and checks if admin logged, then remove flight from DB and also remove all it's dependencies
     */
    public function user_delete_airline(Request $request) {
        $this->abort_if_no_admin();

        if(!$request->input('airline'))
            abort(400, "Missing airline id.");
        $airplanes = DB::table('airplanes')->where('airline', '=', $request->input('airline'))->get();
        foreach($airplanes as $airplane) {
            $this->delete_airplane($airplane->id);
        }
        $flights = DB::table('flights')->where('airline', '=', $request->input('airline'))->get();
        foreach($flights as $flight) {
            $this->delete_flight($flight->flight_number);
        }
        $deleted = DB::table('airlines')->where('airline', $request->input('airline'))->delete();
        if (!$deleted)
            abort(400, 'Not found rows for delete in table airlines');
    }

    /**
     * Returns JSON containing information about all users in DB
     */
    public function get_users () {
        $this->abort_if_no_admin();
        $users = DB::table('users')->get();

        $user_arr = array();
        foreach ($users as $user) {
            array_push($user_arr, $user);
        }
        return json_encode($user_arr);

    }


}