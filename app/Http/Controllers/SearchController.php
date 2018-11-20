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
    public function store(Request $request)
    {
        print_r($request->all());
        
        return "origin";
    }
    public function getForm()
    {
        return "get successful";
    }
    public function postProfile()
    {
        //
    }

    public function update($id)
    {
        return "updating".$id;
    }
    public function anyLogin()
    {
        //
    }

}
