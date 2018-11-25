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

// Route::get('/about', 'PagesController@about');
// Route::get('/chart', 'PagesController@chart');

// try {
//     Route::get('logout', 'LoginController@logout');
// } catch (Exception $e) {
//     abort(404);
// }

// Handle routers in Vue router
Route::get('/{any}', function(){
  return view('vue-index');
})->where('any', '.*');

