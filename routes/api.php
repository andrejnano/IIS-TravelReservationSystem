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

Route::middleware('api')->post('/register', 'API\UserController@register');
