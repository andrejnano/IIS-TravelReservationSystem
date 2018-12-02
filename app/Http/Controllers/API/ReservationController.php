<?php

namespace App\Http\Controllers\API;
use App\Mylibs\Common;

use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use App\Http\Controllers\API\UserController;

class ReservationController extends Controller
{
    /**
     * Creates new empty reservation in database
     *
     * @return void
     */
    public function new_reservation(Request $request) {
        if (!UserController::logged_in()) {
            abort(403);
        }
        try {
            $r = DB::table('reservations')->insert(
                ['created_by' => $_SESSION["uid"], 'payment_status' => 0, 'created_at' => Carbon::now(), 'total_price' => $request['total_price']]
            );
            return json_encode(['new_reservation_id' => DB::getPdo()->lastInsertId()]);
        } catch (Exception $e) {
            abort(500);
        }
    }

    /**
     * Updates temporal ticket to be permanent and adds information about passenger
     *
     * @param Request $request array containing user request
     * @return void
     */
    public function reserve(Request $request) {
        if (!UserController::logged_in()) {
            abort(403);
        }
        try {
            if ($request->input('res_id') && $request->input('ticket_id') && 
            $request->input('email') && $request->input('first_name') && $request->input('last_name')) {
                $reservation = DB::table('reservations')
                    ->where([
                    ['id','=', $request->input('res_id')],
                    ['created_by','=', $_SESSION["uid"]]
                    ])->first();
                // reservation is not mine
                if (!$reservation)
                    abort(403);
                
                $ticket = DB::table('tickets')
                ->where('id','=', $request->input('ticket_id'))->whereNull('reservation')->first();
                if (!$ticket) {
                    abort(404);
                }
                if ($ticket->created_at < Carbon::now()->subMinutes(10)) {
                    $ticket->delete();
                    abort(408);
                }
                DB::table('tickets')
                ->where('id', $request->input('ticket_id'))
                ->update([
                    'reservation' => $request->input('res_id'),
                    'email' => $request->input('email'),
                    'first_name' => $request->input('first_name'),
                    'last_name' => $request->input('last_name')]);
            } else {
                abort(400);
            }
        } catch (Exception $e) {
            abort(500);
        }
            
    }

    /**
     * Removes reservation and its dependencies(tickets) from database
     *
     * @param Request $request array containing user request
     * @return void
     */
    public function delete_reservation(Request $request) {
        if (!UserController::logged_in()) {
            abort(403);
        }
        try {
            if ($request->input('res_id')) {
                $reservation = DB::table('reservations')
                    ->where('id', $request->input('res_id'))->first();

                // reservation is not mine
                if ($reservation->created_by != $_SESSION["uid"])
                    abort(403);
                DB::table('tickets')
                ->where('reservation', '=', $reservation->id)->delete();
                DB::table('reservations')
                    ->where('id', $request->input('res_id'))->delete();
            } else {
                abort(400);
            }
        } catch (Exception $e) {
            abort(500);
        }
            
    }


    protected function obj_rep_reservation($reservation) {
        $tickets = DB::table('tickets')->where('reservation', '=', $reservation->id)->get();
        foreach ($tickets as $t) {
            $t->flight = DB::table('flights')->where('flight_number', '=', $t->flight)->first();
        }
        $reservation->tickets = $tickets;
        return $reservation;
    }
    /**
     * Returns all actual reservations created by current user
     */
    public function my_reservations() {
        if (!UserController::logged_in()) {
            abort(403);
        }
        try {
            // $reservations = DB::table('reservations')
            //     ->where([['created_by', '=', $_SESSION["uid"]], ['created_at', '>', time()]])->get();
            $uid = DB::connection()->getPdo()->quote($_SESSION["uid"]);
            // $time = Carbon::now();
            $time = time();

            $reservations = DB::select("
            SELECT reservations.id, payment_status, reservations.created_at, MIN(flights.departure_time) as min_d, 
                COUNT(*) as count, SUM(cost) as total_cost
            FROM reservations, tickets, flights
            WHERE reservations.created_by = $uid && tickets.reservation = reservations.id
                && tickets.flight = flights.flight_number
            GROUP BY reservations.id
            HAVING MIN(flights.departure_time) > $time
            ");
            $reservation_arr_filled = array();
            foreach ($reservations as $reservation) {
                array_push($reservation_arr_filled, $this->obj_rep_reservation($reservation));
            }
            $empty = DB::select("
            SELECT reservations.id, reservations.created_at
            FROM reservations
            WHERE reservations.created_by = $uid && NOT EXISTS (
                SELECT null
                FROM tickets
                WHERE tickets.reservation = reservations.id
            )
            ");
            $reservation_arr_empty = array();
            foreach ($empty as $empty_r) {
                array_push($reservation_arr_empty, $this->obj_rep_reservation($empty_r));
            }

            $dict['filled'] = $reservation_arr_filled;
            $dict['empty'] = $reservation_arr_empty;
            return json_encode($dict);
        } catch (Exception $e) {
            abort(500);
        }   
    }


    /**
     * Show tickets contained within reservation
     *
     * @param Request $request Request from frontend
     * @return void
     */
    public function reservation_tickets (Request $request) {
        if (!UserController::logged_in()) {
            abort(403);
        }
        try {
            if ($request->input('res_id')) {
                $tickets = DB::table('tickets')->where('reservation', '=', $request->input('res_id'))->get();
                $ticket_arr = array();
                foreach ($tickets as $ticket) {
                    array_push($ticket_arr, $ticket);
                }
                return json_encode($ticket_arr);
            } else {
                abort(400);
            }
        } catch (Exception $e) {
            abort(500);
        }   
    }

    /**
     * Delete ticket and set seat as free
     *
     * @param Request $request Request from frontend
     * @return void
     */
    public function return_ticket (Request $request) {
        if (!UserController::logged_in()) {
            abort(403);
        }
        try {
            if ($request->input('ticket_id')) {
                $ticket = DB::table('tickets')
                    ->where('id', '=', $request->input('ticket_id'))->first();
                // cannot delete someone's else ticket
                if (DB::table('reservations')->where('id', '=', $ticket->reservation)->first()->created_by != $_SESSION['uid'])
                    abort(403);
                $deleted = DB::table('tickets')
                    ->where('id', $request->input('ticket_id'))->delete();
                if (!$deleted)
                    abort(400);
            } else {
                abort(400);
            }
        } catch (Exception $e) {
            abort(500);
        }   
    }

}
