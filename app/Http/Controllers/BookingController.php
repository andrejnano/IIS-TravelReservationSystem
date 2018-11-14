<?php

namespace App\Http\Controllers;
use App\Mylibs\Common;

use Illuminate\Http\Request;

class BookingController extends Controller
{
    public function index()
    {
        return view('pages.booking');
    }
    public function show(Request $request, $id)
    {
        // $common = new common();
        // // print_r($request->all());
        // $request_arr = $request->all();
      
        // // $request_arr['origin']
        // // $request_arr['destination']

        // $results = \DB::select('select city FROM airports', [1]);
        // $origin = $results[$request_arr['origin']]->{"city"};
        // $destination = $results[$request_arr['destination']]->{"city"};
        // $results  = \DB::select(
        // "SELECT flights.flight_number , flights.departure_time, flights.arrival_time
        // FROM flights 
        // WHERE flights.origin IN (
        //   SELECT airport_code FROM airports WHERE airports.city = '$origin'
        // ) 
        // AND flights.destination IN (
        //   SELECT airport_code FROM airports WHERE airports.city = '$destination');");

        // if (!sizeof($results)) {
        //     return "No direct flight found";
        // }
        // $common->printTable($results);
        return view('pages.booking.show_flights')->with('args', $request->all());
        // echo "<tr>\n";
        // foreach($results[0] as $key=>$value) {
        //     echo "<th>".$key."</th>\n";
        // }
        // echo "</tr>\n";
        // foreach($results as $r){
        //     // echo "result".$r;
        //     echo "<tr>\n";
        //     foreach($r as $key=>$value) {
        //         echo "<td>".$value."</td>\n";
        //     }
        //     echo "</tr>\n";
        // }

        // $combo = array();
        // foreach($results as $r){
        //     array_push($combo, $r->{"city"}.": ".$r->{"country"});
        // }
        return ;
    }
    public function store(Request $request)
    {
        // dd(request()->all());

        // $input = Input::only("origin");
        print_r($request->all());
        
        return "origin";
        // return "store successful ";
        // for( $request->all() as $key=>$value) {

        // }
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
