<?php

use Illuminate\Http\Request;
/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', 'PagesController@index');
Route::get('/about', 'PagesController@about');
Route::get('/chart', 'PagesController@chart');

// try {
//     Route::get('logout', 'LoginController@logout');
// } catch (Exception $e) {
//     abort(404);
// }

Route::get('/hello', function () {
    return "Hello World!";
});

Auth::routes(['verify' => true]);

Route::get('/dashboard', 'DashboardController@index');
Route::get('/flight/{flight_number}', function ($flight_number) {
    return view('pages.search.flight')->with("flight", App\Flight::WHERE('flight_number', $flight_number)->first());
})->name('flight');
// Auth::routes();

// Route::get('/dash', 'HomeController@index')->name('home');

Auth::routes();

// Route::get('/home', 'HomeController@index')->name('home');
