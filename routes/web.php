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
Route::get('/chart', 'PagesController@chart');
Route::resource('/search', 'SearchController');
Route::get('logout', 'LoginController@logout');

Route::get('/hello', function () {
    return "Hello World!";
});

Auth::routes(['verify' => true]);

Route::get('/dashboard', 'DashboardController@index');

// Auth::routes();

// Route::get('/dash', 'HomeController@index')->name('home');

Auth::routes();

Route::get('/home', 'HomeController@index')->name('home');
