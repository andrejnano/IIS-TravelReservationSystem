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
     * Function determines number of all free seats, temporary reserved seats are subtracted
     *
     * @param stdClass $r One row of flight from select
     * @return int number of all free seats
     */
    // protected function get_free_seats($r, $price) {
    //     return [
    //         [$r->fclass_seats_free - $this->count_full_class($r, "F"), class_price($r, 'first', $price)],
    //         [$r->bclass_seats_free - $this->count_full_class($r, "B"), class_price($r, 'business', $price)],
    //         [$r->eclass_seats_free - $this->count_full_class($r, "E"), class_price($r, 'economy', $price)]
    //     ];
    // }
    /**
     * Checks if enough seats free in specified class, if no class selected cheapest possible returned
     * @return string '' if not enough empty seats, or class selected
     */
    protected function check_tmp_reservations($r, Request $request, $price) {
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
                    return [$price_f > 0 ? '' : $price_f, $price_f];
                case 'business':
                    return [$price_b > 0 ? '' : $price_b, $price_b];
                case 'economy':
                    return [$price_e > 0 ? '' : $price_e, $price_e];
            }
        }
        if ($price_e > 0 && ($request['min_price'] ? ((float)$request['min_price'] <= $price_e) : 1) && ($request['max_price'] ? ($price_e <= (float)$request['max_price']) : 1)) {
            return ['economy', $price_e];
        } else if ($price_b > 0 && ($request['min_price'] ? ((float)$request['min_price'] <= $price_b) : 1) && ($request['max_price'] ? ($price_b <= (float)$request['max_price']) : 1)) {
            return ['business', $price_b];
        } else if ($price_f > 0 && ($request['min_price'] ? ((float)$request['min_price'] <= $price_f) : 1) && ($request['max_price'] ? ($price_f <= (float)$request['max_price']) : 1)) {
            return ['first', $price_f];
        }

        return ["first", -1];
    }

    /**
     * Creates obj representation of row from sql flight table, plus some additional data from other tables
     *
     * @param stdClass $r One row of flight from select
     * @return array object_representation
     */
    protected function create_object_representation($r, Request $request) {
        $row_array["flight_number"] = $r->flight_number;
        $row_array["departure_time"] = date('Y-m-d G:i:s', strtotime($r->departure_time));
        
        $flight_time = (strtotime($r->arrival_time) - strtotime($r->departure_time)) / 60;
        $flight_min = $flight_time % 60;
        $flight_hour = $flight_time / 60;
        $square_cost = 10;
        $start_price = 0.025;
        $price = $start_price*200 + $start_price * ($flight_time + $flight_time*$flight_time/$square_cost);
        [$seat_class, $price] = $this->check_tmp_reservations($r, $request, $price);
        // class_price($r, $seat_class, $price);
        if (!$seat_class || $price < 0)
            return NULL;

        if ($request['min_price'] && $price < $request['min_price']) {
            return NULL;
        }
        if ($request['max_price'] && $price > $request['max_price']) {
            return NULL;
        }
        $flight_time_str = sprintf("%dh %dm\n", $flight_hour, $flight_min);
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
     * Searches flights in SQL database, which satisfies specified condition
     *
     * @param Request $request_arr Array containing specified search condition from user
     * @return array containing object representation of selected flights
     */
    protected function search_flights($request_arr) {
        $pdo = DB::connection()->getPdo();
        $origin = $pdo->quote($request_arr['origin']);
        $destination = $pdo->quote($request_arr['destination']);
        $departure_before = $pdo->quote($request_arr['depart_before']);
        $departure_after = $pdo->quote($request_arr['depart_after']);
        if (!isset($request_arr['tickets'])) {
            $request_arr['tickets'] = 1;
        }
        $number_of_tickets = $pdo->quote($request_arr['tickets']);
        $seat_class = $request_arr['class'];

        if (!$departure_after)
            $departure_after = Carbon::now();

        $select_query= $this->get_flight_query();
        if ($request_arr['origin']) {
            $select_query .= $this->set_location("o", $origin);
        }
        if ($request_arr['destination']) {
            $select_query .= $this->set_location("d", $destination);
        }
        if ($request_arr['departure_date']) {
            $departure_after = strtotime($request_arr['departure_date']);
            $departure_before = strtotime("+1 day", $departure_after);
            $select_query .= " UNIX_TIMESTAMP(departure_time) < $departure_before AND ";
            $select_query .= " UNIX_TIMESTAMP(departure_time) > $departure_after AND ";
        } else {
            if ($request_arr['depart_before']) {
                $select_query .= " departure_time < $departure_before AND ";
            }
            if ($request_arr['depart_after']) {
                $select_query .= " departure_time > $departure_after AND ";
            }
        }
        
        [$out_query, $class_selected] = $this->select_class($seat_class, $number_of_tickets);
        $select_query .= $out_query;

        $select_query .= $this->get_db_cross_cond();
        
        try {
            $results  = DB::select($select_query);
        } catch (Exception $e) {
            abort(500);
        }

        $return_arr = array();
        foreach($results as $r){
            $row_array['there'] = $this->create_object_representation($r, $request_arr);

            if (isset($request_arr['min_t']) || isset($request_arr['max_t']) || $request_arr['arrival_date']) {
                
                $return_query = $this->get_flight_query();
                $return_query .= "o.airport_code = ".$pdo->quote($r->d_airport)." AND ";
                $return_query .= "d.airport_code = ".$pdo->quote($r->o_airport)." AND ";
                $arrive_ts = strtotime($r->arrival_time);
                if ($request_arr['arrival_date']) {
                    $arrive_after = strtotime($request_arr['arrival_date']);
                    $arrive_before = strtotime("+1 days", $arrive_after);
                    $return_query .= " UNIX_TIMESTAMP(arrival_time) < ".$pdo->quote($arrive_before)." AND ";
                    $return_query .= " UNIX_TIMESTAMP(arrival_time) > ".$pdo->quote($arrive_after)." AND ";
                } else {
                    if (isset($request_arr['min_t'])) {
                        $min_t = (int)$request_arr['min_t'];
                    } else {
                        $min_t = 0;    
                    } 
                    $return_query .= " UNIX_TIMESTAMP(departure_time) > ".$pdo->quote(strtotime("+$min_t days", $arrive_ts))." AND ";
                    if (isset($request_arr['max_t'])) {
                        $max_t = (int)$request_arr['max_t'];
                        $return_query .= " UNIX_TIMESTAMP(departure_time) < ".$pdo->quote(strtotime("+$max_t days", $arrive_ts))." AND ";
                    }
                }
                [$out_query, $rev_class] = $this->select_class($seat_class, $number_of_tickets);
                $return_query .= $out_query;
                $return_query .= $this->get_db_cross_cond();

                try {
                    $returns  = DB::select($return_query);
                } catch (Exception $e) {
                    abort(500);
                }

                $return_flight_arr = array();
                foreach($returns as $ret) {
                    $back_flight = $this->create_object_representation($ret, $request_arr);
                    if ($back_flight) {
                        array_push($return_flight_arr, $back_flight);
                    }
                }
                $row_array['back'] = $return_flight_arr;
                if (!empty($return_flight_arr) && $row_array['there'] && $row_array['back'])
                    array_push($return_arr,$row_array);
            } else if ($row_array['there']) {
                array_push($return_arr,$row_array);
            }
        }
        return $return_arr;
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
        return DB::select($flight_query)[0];
    }

    /**
     * Search for specific flight in databse and create object representation
     *
     * @param Request $request user arguments
     * @return array object representation of flight from database
     */
    protected function get_flight(Request $request) {
        $f1 = $this->select_flight($request['f1']);
        $class_selected = false;
        if (in_array($request['class'], ['first', 'business', 'economy'])) {
            $class_selected = true;
        }

        $return_arr = array();
        $tmp_obj = $this->create_object_representation($f1, $request);
        array_push($return_arr, $tmp_obj);
        if (isset($request['f2'])) {
            $f2 = $this->select_flight($request['f2']);
            $tmp_obj = $this->create_object_representation($f2, $request);
            array_push($return_arr, $tmp_obj);
        }
        return $return_arr;
    }

    public function show(Request $request)
    {
        try {
            $return_arr = $this->search_flights($request);
            return json_encode($return_arr);
        } catch (Exception $e) {
            abort(400);
        }
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
        $max = $flight['tickets'];
        for ($i = 0; $i < $max; $i++) {
            DB::table('tickets')->insert(
                ['cost' => $flight['price'],
                'flight' => $flight['flight_number'],
                'seat_class' => $this->class_convert($request['class']),
                'created_at' => Carbon::now()]
            );
            $f = DB::getPdo()->lastInsertId();
            array_push($return_arr, $f);
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
            $tmp_ticket = $this->insert_tickets($flight_arr[0], $request);
            if (!$tmp_ticket)
                abort(409);
            $flight_arr[0]["ticket_ids"] = $tmp_ticket;
            if (isset($flight_arr[1])) {
                $tmp_ticket = $this->insert_tickets($flight_arr[1], $request);
                if (!$tmp_ticket)
                    abort(409);
                $flight_arr[1]["ticket_ids"] = $tmp_ticket;
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
        if (!isset($request["class"]) || !isset($request["f1"]) || !isset($request["tickets"])) {
            abort(400);
        }
        try {
            $return_arr = $this->get_flight($request);
            $return_arr = $this->tmp_ticket($return_arr, $request);
            return json_encode($return_arr);
        } catch (Exception $e) {
            abort(400);
        }
    }
}
