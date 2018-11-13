<?php

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
Route::resource('/booking', 'BookingController');
// Route::controller('/booking', 'BookingController');

// Route::get('/booking', 'PagesController@booking');
// Route::post('/booking/form', function () {
//     return "It works";
// });
Route::get('/hello', function () {
    return "Hello World!";
});
