<?php

namespace App\Http\Controllers\API;
use App\Mylibs\Common;
use Cookie;

use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    /**
     * Determines if user is logged in, if yes it will set new timestamp
     * If timestamp is older, then 30 minutes client is logged out
     *
     * @return boolean true if logged false otherwise
     */
    public static function logged_in() {
        session_start();
        if (!isset($_SESSION['uid']) || !isset($_SESSION['user']))
            return false;
        if (isset($_SESSION['LAST_ACTIVITY']) && (time() - $_SESSION['LAST_ACTIVITY'] > 1800)) {
            // last request was more than 30 minutes ago
            session_unset();     // unset $_SESSION variable for the run-time 
            session_destroy();   // destroy session data in storage
        } else if (isset($_SESSION["user"]) && DB::table('users')->where('id', '=', $_SESSION['uid'])->first()) {
            $_SESSION['LAST_ACTIVITY'] = time(); // update last activity time stamp
            return true;
        }
        return false;
    }

    /**
     * Create new session and set $_SESSION super-global log in variables
     *
     * @param Request User request
     * @return void
     */
    public function login(Request $request) {
        if ($this->logged_in())
            abort(400);
        if (isset($_SESSION["user"]))
            redirect('/dashboard');
        $user = DB::table('users')->where('email', '=', $request->input('email'))->first();
        if (!$user) {
            abort(403);
        }
        else if (Hash::check($request->input('password'), $user->password)) {
            if ($user->is_admin) {
                $_SESSION["user"] = "admin";
            } else {
                $_SESSION["user"] = "user";
            }
            $_SESSION["uid"] = $user->id;
            $_SESSION['LAST_ACTIVITY'] = time();
            redirect('/dashboard');
        } else {
            abort(403);
        }
    }

    /**
     * Creates new user and logs him in
     *
     * @param Request User authentication information
     * @return void
     */
    public function register(Request $request) {
        if ($this->logged_in())
        redirect('/dashboard');
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
                $_SESSION["user"] = "user";
                $_SESSION["uid"] = DB::getPdo()->lastInsertId();
                $_SESSION['LAST_ACTIVITY'] = time();
                redirect('/dashboard');
            } catch (Exception $e) {
                abort(500);
            }
        }
    }

    /**
     * Logs active user out
     *
     * @return void
     */
    public function logout() {
        if ($this->logged_in()) {
            session_unset();     // unset $_SESSION variable for the run-time 
            session_destroy();   // destroy session data in storage
        } else {
            abort(400);
        }
    }

    public function session() {
        if($this->logged_in()){
            $user = DB::table('users')->select('first_name', 'last_name')->where('id', $_SESSION["uid"])->get();
            $user_arr = array();
            foreach ($user as $u) {
                array_push($user_arr, $u);
            }
            return json_encode($user_arr[0]);
        }
        abort(401, "User not logged");
    }
}
