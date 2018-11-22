<?php

namespace App\Http\Controllers;
use App\Mylibs\Common;

use Illuminate\Http\Request;

class SearchController extends Controller
{
    public function index()
    {
        return view('pages.search');
    }
    public function show(Request $request, $id)
    {
        return view('pages.search.show_flights')->with('args', $request->all());
        
    }
}
