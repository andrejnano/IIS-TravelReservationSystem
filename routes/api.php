<?php

use Illuminate\Http\Request;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/


Route::middleware('api')->get('/search', 'API\SearchController@show');

Route::middleware('api')->get('/flight', 'API\SearchController@ticket_detail');

Route::middleware('api')->post('/reservation', 'API\ReservationController@new_reservation');

Route::middleware('api')->post('/reserve', 'API\ReservationController@reserve');

Route::middleware('api')->post('/delete_reservation', 'API\ReservationController@delete_reservation');

Route::middleware('api')->post('/login', 'API\UserController@login');

Route::middleware('api')->post('/logout', 'API\UserController@logout');

Route::middleware('api')->get('/logout', 'API\UserController@logout');

Route::middleware('api')->get('/session', 'API\UserController@session');

Route::middleware('api')->post('/register', 'API\UserController@register');

Route::middleware('api')->post('/new_password', 'API\UserController@new_password');

Route::middleware('api')->post('/update_information', 'API\UserController@update_information');

Route::middleware('api')->post('/add_flight', 'API\AdminController@add_flight');

Route::middleware('api')->post('/add_airline', 'API\AdminController@add_airline');

Route::middleware('api')->post('/add_airport', 'API\AdminController@add_airport');

Route::middleware('api')->post('/add_airplane', 'API\AdminController@add_airplane');

Route::middleware('api')->post('/add_user', 'API\AdminController@add_user');

Route::middleware('api')->post('/update_airline', 'API\AdminController@update_airline');

Route::middleware('api')->post('/update_user', 'API\AdminController@update_user');

Route::middleware('api')->post('/delete_user', 'API\AdminController@delete_user');

Route::middleware('api')->post('/my_reservations', 'API\ReservationController@my_reservations');

Route::middleware('api')->post('/reservation_tickets', 'API\ReservationController@reservation_tickets');

Route::middleware('api')->post('/return_ticket', 'API\ReservationController@return_ticket');

Route::middleware('api')->post('/delete_flight', 'API\AdminController@user_delete_flight');

Route::middleware('api')->post('/delete_airplane', 'API\AdminController@user_delete_airplane');

Route::middleware('api')->post('/delete_airline', 'API\AdminController@user_delete_airline');

Route::middleware('api')->get('/airports', 'API\GetTableController@get_airports');

Route::middleware('api')->get('/flights', 'API\GetTableController@get_flights');

Route::middleware('api')->get('/new_flights', 'API\GetTableController@get_new_flights');

Route::middleware('api')->get('/airplanes', 'API\GetTableController@get_airplanes');

Route::middleware('api')->get('/airlines', 'API\GetTableController@get_airlines');

Route::middleware('api')->get('/users', 'API\AdminController@get_users');

Route::middleware('api')->post('/pay', 'API\UserController@pay');