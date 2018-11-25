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
    public function login(Request $request) {
        session_start();
        if (isset($_SESSION["user"]))
            redirect('/dashboard');
        $user = DB::table('users')->where('email', '=', $request['email'])->first();
        if (!$user) {
            abort(403);
        }
        else if (Hash::check($request['password'], $user->password)) {
            if ($user->is_admin) {
                $_SESSION["user"] = "admin";
            } else {
                $_SESSION["user"] = "user";
            }
            $_SESSION["uid"] = $user->id;
            redirect('/dashboard');
        } else {
            abort(403);
        }
    }

    public function register(Request $request) {
        // session_start();
        session_start();
        if (isset($_SESSION["user"]))
            redirect('/dashboard');
        if (!isset($request['first_name']) || !isset($request['last_name']) ||
            !isset($request['email']) || !isset($request['password'])) {
            
                echo ("abort 400");
            // abort(400);
        }
        $user = DB::table('users')->where('email', '=', $request['email'])->first();
        if ($user) {
            abort(409);
        }
        else {
            try {
                DB::table('users')->insert([
                    "first_name" => $request["first_name"],
                    "last_name" => $request["last_name"],
                    "email" => $request["email"],
                    "password" => Hash::make($request["password"])
                    ]);
                $_SESSION["user"] = "user";
                $_SESSION["uid"] = DB::getPdo()->lastInsertId();
                redirect('/dashboard');
            } catch (Exception $e) {
                abort(500);
            }
        }
    }
    public function logout(Request $request) {
        session_start();
        session_destroy();
        // redirect('/login');
    }
}
