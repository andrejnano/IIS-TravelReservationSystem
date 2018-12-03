<?php

namespace App\Http\Controllers\API;
use App\Mylibs\Common;

use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class SearchController extends Controller
{
    /**
     * Creates header of flight query to sql database, contains column and tables specification
     *
     * @return string header of query
     */
    protected function get_flight_query() {
        return "
        SELECT  flight_number, departure_time,	arrival_time, airplane, airline,
                fclass_seats_free, bclass_seats_free, eclass_seats_free,
                o.airport_code AS o_airport, o.city AS o_city, o.country AS o_country,
                d.airport_code AS d_airport, d.city AS d_city, d.country AS d_country
            FROM flights f, airports o, airports d
            WHERE
        ";
    }

    /**
     * Cross join condition for sql query, should be appended at the end of query
     *
     * @return string cross condition
     */
    protected function get_db_cross_cond() {
        return "f.origin = o.airport_code and f.destination = d.airport_code";
    }

    /**
     * Undocumented function
     *
     * @param string $location_key o == origin, d == destination
     * @param string $location_val searched string, DBX || USA || United Kingdom
     * @return string part of query defining location (origin/destination)
     */
    protected function set_location($location_key, $location_val) {
        $out = "
        ( $location_key.city = $location_val OR
            $location_key.country = $location_val OR
            $location_key.airport_code = $location_val )
        AND ";
        return $out;
    }

    /**
     *  Checks if enough seats are free in specified class
     *
     * @param string $class seat class fclass_seats_free || bclass_seats_free || eclass_seats_free
     * @param int $number_of_tickets number of tickets to be ordered
     * @return string Sql query with specified number of seats required
     */
    protected function seat_filter($class, $number_of_tickets) {
        $out = "
        $class >= $number_of_tickets
        AND ";
        return $out;
    }

    /**
     * Calculates price of seat in specified seat class
     *
     * @param stdClass $r One row of flight from select
     * @param string $class Seat class economy || business || first
     * @param float $price Starting price of seat, same for all classes
     * @return void price of seat
     */
    protected function class_price($r, $class, $price) {
        switch ($class) {
            case 'economy':
                return $price + ($price / ($r->eclass_seats_free + 1)/2);
            case 'business':
                return 2.5 * ($price + ($price / ($r->bclass_seats_free + 1)/2));
            case 'first':
                return 6 * ($price + ($price / ($r->fclass_seats_free + 1)/2));
        }
    }

    /**
     * Appends requested seat class to query
     *
     * @param string $seat_class 'first', 'business', 'economy'
     * @param int $number_of_tickets number of requested tickets, which user want to reserve
     * @return [extended_sql_query, true if class was selected]
     */
    protected function select_class($seat_class, $number_of_tickets) {
        $out_query = "";
        if (in_array($seat_class, ['first', 'business', 'economy'])) {
            $class_selected = true;
            switch ($seat_class) {
                case "first":
                    $out_query .= $this->seat_filter("fclass_seats_free", $number_of_tickets);
                    break;
                case "business":
                    $out_query .= $this->seat_filter("bclass_seats_free", $number_of_tickets);
                    break;
                case "economy":
                    $out_query .= $this->seat_filter("eclass_seats_free", $number_of_tickets);
                    break;
                }
        } else {
            $class_selected = false;
            $out_query .= " (fclass_seats_free >= $number_of_tickets or bclass_seats_free >= $number_of_tickets or eclass_seats_free >=  $number_of_tickets) AND ";

        }
        return [$out_query, $class_selected];
    }

    /**
     * Counts number of temporary taken seats in specified seat class
     *
     * @param stdClass $r One row of flight from select
     * @param string $class 'first', 'business', 'economy'
     * @return int count of taken seats
     */
    protected function count_full_class($r, $class) {
        $count = 0;
        $tmp_reservations = DB::table('tickets')
            ->where([
                ['flight','=', $r->flight_number],
                ['seat_class', '=', $class],
                ['created_at', '<', Carbon::now()->subMinutes(10)]
            ])->whereNull('reservation')->delete();

        $count = count(DB::table('tickets')
        ->where([
            ['flight','=', $r->flight_number],
            ['seat_class', '=', $class]
        ])->whereNull('reservation')->get());
        return $count;
    }

    /**
     * Checks if enough seats free in specified class, if no class selected cheapest possible returned
     * @return string '' if not enough empty seats, or class selected
     */
    protected function check_tmp_reservations($r, Request $request, $price, $curr_price) {
        $number_of_tickets = 1;
        $class_selected = false;
        if ($request['tickets']) {
            $number_of_tickets = $request['tickets'];
        }
        if ($request['class']) {
            $class_selected = true;
            $seat_class = $request['class'];
        }
        $price_f = ($r->fclass_seats_free - $this->count_full_class($r, "F")) > $number_of_tickets ? $this->class_price($r, 'first', $price) : -1;
        $price_b = ($r->bclass_seats_free - $this->count_full_class($r, "B")) > $number_of_tickets ? $this->class_price($r, 'business', $price) : -1;
        $price_e = ($r->eclass_seats_free - $this->count_full_class($r, "E")) > $number_of_tickets ? $this->class_price($r, 'economy', $price) : -1;
        // [$f_free, $b_free, $e_free] = $this->get_free_seats($r, $price);
        if ($class_selected) {
            switch ($seat_class) {
                case 'first':
                    return [$price_f > 0 ? 'first' : '', $price_f];
                case 'business':
                    return [$price_b > 0 ? 'business' : '', $price_b];
                case 'economy':
                    return [$price_e > 0 ? 'economy' : '', $price_e];
            }
        }
        if ($price_e > 0 && /* ($request['min_price'] ? ((float)$request['min_price'] <= $price_e) : 1) && */ ($request['max_price'] ? ($price_e + $curr_price <= (float)$request['max_price']) : 1)) {
            return ['economy', $price_e];
        } else if ($price_b > 0 && /* ($request['min_price'] ? ((float)$request['min_price'] <= $price_b) : 1) && */ ($request['max_price'] ? ($price_b + $curr_price <= (float)$request['max_price']) : 1)) {
            return ['business', $price_b];
        } else if ($price_f > 0 && /* ($request['min_price'] ? ((float)$request['min_price'] <= $price_f) : 1) && */ ($request['max_price'] ? ($price_f + $curr_price <= (float)$request['max_price']) : 1)) {
            return ['first', $price_f];
        }

        return ["first", -1];
    }

    /**
     * determine flight time from first and last timestamp stored as user readable string
     */
    protected function get_flight_time($first, $last) {
        $flight_time = (strtotime($first) - strtotime($last)) / 60;
        $flight_min = $flight_time % 60;
        $flight_hour = $flight_time / 60;
        $flight_time_str = sprintf("%dh %dm\n", $flight_hour, $flight_min);
        return [$flight_time, $flight_time_str];
    }
    /**
     * create obhect representation for direct flights
     * curr_price used as filter if it is exceeded, then return NULL, else return object representation
     */
    protected function obj_rep_flight($r, Request $request, $curr_price) {
        $row_array["flight_number"] = $r->flight_number;
        $row_array["departure_time"] = date('Y-m-d G:i:s', strtotime($r->departure_time));
        $row_array["arrival_time"] = date('Y-m-d G:i:s', strtotime($r->arrival_time));

        [$flight_time, $flight_time_str] = $this->get_flight_time($r->arrival_time, $r->departure_time);
        $start_price = 0.55;
        $price = $start_price*200 + $start_price * ($flight_time + 1/($flight_time));
        [$seat_class, $price] = $this->check_tmp_reservations($r, $request, $price, $curr_price);
        // class_price($r, $seat_class, $price);
        if (!$seat_class || $price < 0)
            return NULL;

        // if ($request['min_price'] && $price + $curr_price < $request['min_price']) {
        //     return NULL;
        // }
        if ($request['max_price'] && $price + $curr_price > $request['max_price']) {
            return NULL;
        }
        $row_array['airplane'] = DB::table('airplanes')->select('producer','model', 'airline')->WHERE('id','=', $r->airplane)->first();
        $row_array['airline'] = DB::table('airlines')->WHERE('airline','=', $r->airline)->first();
        $row_array["flight_time"] = $flight_time_str;
        $row_array["price"] = (int)$price;
        $row_array["seat_class"] = $seat_class;
        $row_array["tickets"] = $request['tickets'];
        $row_array["origin"] =
            array("airport" => $r->o_airport,
                "city" => $r->o_city,
                "country" => $r->o_country
            );
        $row_array["destination"] =
            array("airport" => $r->d_airport,
                "city" => $r->d_city,
                "country" => $r->d_country
            );
        return $row_array;
    }
    /**
     * Creates obj representation of row from sql flight table, plus some additional data from other tables
     *
     * @param stdClass $r One row of flight from select
     * @return array object_representation
     */
    protected function create_object_representation($r, Request $request) {
        $all = array();
        $curr_price = 0;
        foreach($r as $flight) {
            $obj = $this->obj_rep_flight($flight, $request, $curr_price);
            if ($obj) {
                $curr_price += $obj['price'];
                array_push($all, $obj);
            } else {
                return NULL;
            }
        }
        if ($curr_price <= 0)
            return NULL;
            // dd($all);
        $tmp1 = end($all)['arrival_time'];
        $tmp2 = $all[0]['departure_time'];
        $all['total_time'] = $this->get_flight_time($tmp1, $tmp2)[1];
        $all['total_time_mins'] = $this->get_flight_time($tmp1, $tmp2)[0];

        if ($request['min_price'] && $curr_price <= $request['min_price']) {
            return NULL;
        }
        if ($request['max_price'] && $curr_price >= $request['max_price']) {
            return NULL;
        }
        $all['total_price'] = $curr_price;
        return $all;
    }

    /**
     * Select apropriate direct flight
    * $dest_airport if true only destination airport code was set no need to search city or country
    * $origin_airport same as before just for origin
    * $direction direction 0 there 1 back
    */
    protected function select_flights_direct(Request $request_arr, $dest_airport, $origin_airport, $direction) {
        $pdo = DB::connection()->getPdo();
        $origin = $pdo->quote($request_arr['origin']);
        $destination = $pdo->quote($request_arr['destination']);
        $query = $this->get_flight_query();

        if (!isset($request_arr['tickets'])) {
            $request_arr['tickets'] = 1;
        }
        $number_of_tickets = $pdo->quote($request_arr['tickets']);
        if ($dest_airport) {
            if ($request_arr['destination'])
            $query .= "d.airport_code = $destination AND ";
        } else {
            if ($request_arr['destination'])
            $query .= $this->set_location("d", $destination);
        }
        if ($origin_airport) {
            // $request_arr['origin'] by mal byt vzdy zadany
            if ($request_arr['origin'])
                $query .= "o.airport_code = $origin AND ";
        } else {
            if ($request_arr['origin'])
                $query .= $this->set_location("o", $origin);
        }
        if ($direction) {
            if ($request_arr['arrival_date'] && $request_arr['arrival_date'] != 'undefined') {
                $arrive_after = strtotime($request_arr['arrival_date']);
                $arrive_before = strtotime("+1 days", $arrive_after);
                $query .= " UNIX_TIMESTAMP(arrival_time) < ".$pdo->quote($arrive_before)." AND ";
                $query .= " UNIX_TIMESTAMP(arrival_time) > ".$pdo->quote($arrive_after)." AND ";
            } else {
                $arrive_ts = strtotime($request_arr['arrival_time']);
                if (isset($request_arr['min_t'])) {
                    $min_t = (int)$request_arr['min_t'];
                } else {
                    $min_t = 0;
                }
                $query .= " UNIX_TIMESTAMP(departure_time) > ".$pdo->quote(strtotime("+$min_t days", $arrive_ts))." AND ";
                if (isset($request_arr['max_t']) && !is_null($request_arr['max_t']) /* !$dest_airport */) {
                    $max_t = (int)$request_arr['max_t'];
                    $query .= " UNIX_TIMESTAMP(departure_time) < ".$pdo->quote(strtotime("+$max_t days", $arrive_ts))." AND ";
                }
            }
        } else {
            $departure_before = $pdo->quote($request_arr['depart_before']);
            $departure_after = $pdo->quote($request_arr['depart_after']);
            if (!$departure_after)
            $departure_after = Carbon::now();
            if ($request_arr['departure_date'] && $request_arr['departure_date'] != 'undefined') {
                $departure_after = strtotime($request_arr['departure_date']);
                $departure_before = strtotime("+1 day", $departure_after);
                $query .= " UNIX_TIMESTAMP(departure_time) < ".$pdo->quote($departure_before)." AND ";
                $query .= " UNIX_TIMESTAMP(departure_time) > ".$pdo->quote($departure_after)." AND ";
            } else {
                if ($request_arr['depart_before']) {
                    $query .= " departure_time < $departure_before AND ";
                }
                if ($request_arr['depart_after']) {
                    $query .= " departure_time > $departure_after AND ";
                }
            }
        }
        [$out_query, $rev_class] = $this->select_class($request_arr['class'], $number_of_tickets);
        $query .= $out_query;
        $query .= $this->get_db_cross_cond();

        try {
            $selected = DB::select($query);
            return $selected;
        } catch (Exception $e) {
            abort(500);
        }
    }
    /**
    * select apropriate flights also not direct possible
    * $dest_airport if true only destination airport code was set no need to search city or country
    * $origin_airport same as before just for origin
    * $direction direction 0 there 1 back
    */
    protected function select_flights(Request $request_arr, $dest_airport, $origin_airport, $direction) {
        $selected = $this->select_flights_direct($request_arr, $dest_airport, $origin_airport, $direction);
        $i = 0;
        foreach($selected as $s) {
            $selected[$i] = array($s);
            $i++;
        }
        if ($i <= 10) {
            $first = $request_arr;
            $dest = $first['destination'];
            $first['destination'] = NULL;
            $first['destination'] = NULL;
            $tmp_date = $first['arrival_date'];
            $first['arrival_date'] = NULL;
            $first_r = $this->select_flights_direct($first, false, $origin_airport, $direction);
            // dd($first_r);
            foreach($first_r as $fr) {
                $second = Request();//$request_arr;
                $second['origin'] = $fr->d_airport;
                if ($dest)
                    $second['destination'] = $dest;
                $second['min_t'] = '0';
                $second['max_t'] = '2';
                $second['arrival_time'] = $fr->arrival_time;
                $first['departure_date'] = $tmp_date;
                $second_r = $this->select_flights_direct($second, $dest_airport, false, true);
                if ($second_r) {
                    array_push($selected, array($fr, $second_r[0]));
                }
            }
        }
        return $selected;
    }

    /**
     * Searches flights in SQL database, which satisfies specified condition
     *
     * @param Request $request_arr Array containing specified search condition from user
     * @return array containing object representation of selected flights
     */
    protected function search_flights($request_arr) {
        $min_t = NULL;
        $max_t = NULL;
        $arrival_date = NULL;

        if ($request_arr['min_t'] || $request_arr['min_t'] === '0')
            $min_t = $request_arr['min_t'];
        if ($request_arr['max_t'] || $request_arr['max_t'] === '0')
            $max_t = $request_arr['max_t'];
        if ($request_arr['arrival_date'] || $request_arr['arrival_date'] === '0')
            $arrival_date = $request_arr['arrival_date'];

        $results = $this->select_flights($request_arr, false, false, false);

        $return_arr = array();
        foreach($results as $r){
            $row_array['there'] = $this->create_object_representation($r, $request_arr);




            if (!is_null($min_t) || !is_null($max_t) || !is_null($arrival_date)) {
                $back_request = $request_arr;
                $back_request['min_t'] = $min_t;
                $back_request['max_t'] = $max_t;
                $back_request['arrival_date'] = $arrival_date;
                $back_request['origin'] = end($r)->d_airport;
                $back_request['destination'] = $r[0]->o_airport;
                $back_request['arrival_time'] = end($r)->arrival_time;

                $returns = $this->select_flights($back_request, true, true, true);

                $return_flight_arr = array();

                foreach($returns as $ret) {
                    $back_flight = $this->create_object_representation($ret, $request_arr);
                    if ($back_flight) {
                        array_push($return_flight_arr, $back_flight);
                    }
                    break;
                }
                $row_array['back'] = $return_flight_arr;
                if (!empty($return_flight_arr) && $row_array['there'] && $row_array['back']) {

                    $row_array['back'] = $return_flight_arr[0];
                    $cur_total_price = $row_array['back']['total_price'] + $row_array['there']['total_price'];
                    $row_array['total_price'] = $cur_total_price;

                    $row_array['total_time'] = round(($row_array['back']['total_time_mins'] + $row_array['there']['total_time_mins']) / 60);
                    array_push($return_arr,$row_array);

                }
            } else if ($row_array['there'] && (is_null($min_t) && is_null($max_t) && is_null($arrival_date))) {
                $cur_total_price = $row_array['there']['total_price'];
                $row_array['total_price'] = $cur_total_price;
                $row_array['total_time'] = round($row_array['there']['total_time_mins'] / 60);
                array_push($return_arr,$row_array);
            }
        }
        return $return_arr;
    }

    /**
     * Acess point for user query from frontend
     */
    public function show(Request $request)
    {
        try {
            if (isset($request['class'])) {
                switch ($request['class']) {
                    case '0':
                        $request['class'] = 'economy';
                    break;
                    case '1':
                        $request['class'] = 'business';
                    break;
                    case '2':
                        $request['class'] = 'first';
                    break;
                }
            }
            $return_arr = $this->search_flights($request);
            return json_encode($return_arr);
        } catch (Exception $e) {
            abort(400);
        }
    }


    /**
     * Inserts into db query specific flight number condition
     *
     * @param string $flight_number ID of the flight
     * @return stdClass One row of flight from select
     */
    protected function select_flight($flight_number) {
        $quoted_flight_num = DB::connection()->getPdo()->quote($flight_number);
        $flight_query = $this->get_flight_query();
        $flight_query .= " flight_number = $quoted_flight_num AND ";
        $flight_query .= $this->get_db_cross_cond();
        $selected = DB::select($flight_query);
        if (!$selected)
            return NULL;
        return $selected[0];
    }

    /**
     * Search for specific flight in databse and create object representation
     *
     * @param Request $request user arguments
     * @return array object representation of flight from database
     */
    protected function get_flight(Request $request) {
        $flight_there = array();
        $tmp = $this->select_flight($request['ft_1']);
        if (!$tmp)
            return NULL;
        array_push($flight_there, $tmp);
        if (isset($request['ft_2'])){
            $tmp = $this->select_flight($request['ft_2']);
            if (!$tmp)
            return NULL;
            array_push($flight_there, $tmp);
        }
        $class_selected = false;
        if (in_array($request['class'], ['first', 'business', 'economy'])) {
            $class_selected = true;
        }

        $return_arr = array();
        $tmp_obj = $this->create_object_representation($flight_there, $request);
        $curr_price = $tmp_obj['total_price'];
        $return_arr['there'] = $tmp_obj;
        if (isset($request['fb_1'])) {
            $flight_back = array();
            $tmp = $this->select_flight($request['fb_1']);
            if (!$tmp)
                return NULL;
            array_push($flight_back, $tmp);
            if (isset($request['fb_2'])){
                $tmp = $this->select_flight($request['fb_2']);
                if (!$tmp)
                    return NULL;
                array_push($flight_back, $tmp);
            }
            $tmp_obj = $this->create_object_representation($flight_back, $request);
            $curr_price += $tmp_obj['total_price'];
            $return_arr['back'] = $tmp_obj;
        }
        $return_arr['total_price'] = $curr_price;
        return $return_arr;
    }

    /**
     * Convert long name of class to short
     *
     * @param string 'first', 'business', economy'
     * @return string short class name
     */
    function class_convert($class) {
        switch($class) {
            case 'first':
                return 'F';
            case 'business':
                return 'B';
            case 'economy':
                return 'E';
        }
        return NULL;
    }

    /**
     * Insert newly created ticket into object representation and database
     *
     * @param array $flight object representation of flight
     * @param Request $request user request
     * @return array Object representation with ticket numbers inserted
     */
    protected function insert_tickets($flight, $request) {
        $return_arr = array();
        /* example 2 */
        // todo error nothing inserted
        $max = $flight['0']['tickets'];
        for ($i = 0; $i < $max; $i++) {
            DB::table('tickets')->insert(
                ['cost' => $flight['0']['price'],
                'flight' => $flight['0']['flight_number'],
                'seat_class' => $this->class_convert($request['class']),
                'created_at' => Carbon::now()]
            );
            $f = DB::getPdo()->lastInsertId();
            array_push($return_arr, $f);

            if (isset($flight['1'])) {
                DB::table('tickets')->insert(
                    ['cost' => $flight['1']['price'],
                    'flight' => $flight['1']['flight_number'],
                    'seat_class' => $this->class_convert($request['class']),
                    'created_at' => Carbon::now()]
                );
                $f = DB::getPdo()->lastInsertId();
                array_push($return_arr, $f);
            }
        }
        return $return_arr;
    }

    /**
     * Create temporal ticket == not connected to user or reservation, should be created on detail of ticket
     *
     * @param array $flight_arr object representation of flight
     * @param Request $request user request
     * @return array object representation of flight with new ticket id
     */
    public function tmp_ticket($flight_arr, $request) {
        try {
            $f2 = DB::getPdo()->lastInsertId();
            $tmp_ticket = $this->insert_tickets($flight_arr['there'], $request);
            if (!$tmp_ticket)
                abort(409);
            $flight_arr['there']["ticket_ids"] = $tmp_ticket;
            if (isset($flight_arr['back'])) {
                $tmp_ticket = $this->insert_tickets($flight_arr['back'], $request);
                if (!$tmp_ticket)
                    abort(409);
                $flight_arr['back']["ticket_ids"] = $tmp_ticket;
            }
            return [$flight_arr];
        } catch (Exception $e) {
            abort(500);
        }
    }

    /**
     * Function for handling user request for showing detail of flight
     *
     * @param Request $request
     * @return json representation of flight, with all information
     */
    public function ticket_detail(Request $request)
    {
        // if (!isset($request["class"]) || !isset($request["f1"]) || !isset($request["tickets"])) {
        //     abort(400);
        // }
        try {
            $return_arr = $this->get_flight($request);
            $return_arr = $this->tmp_ticket($return_arr, $request);
            return json_encode($return_arr);
        } catch (Exception $e) {
            abort(400);
        }
    }
}
