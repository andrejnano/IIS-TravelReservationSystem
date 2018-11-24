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

// Route::get('/booking', 'PagesController@booking');
// Route::post('/booking/form', function () {
//     return "It works";
// });
Route::get('/hello', function () {
    return "Hello World!";
});
