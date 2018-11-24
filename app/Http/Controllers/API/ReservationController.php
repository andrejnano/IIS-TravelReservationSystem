<?php

namespace App\Http\Controllers\API;
use App\Mylibs\Common;

use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ReservationController extends Controller
{
    /**
     * Creates new empty reservation in database
     *
     * @param Request $request array containing user request
     * @return void
     */
    public function new_reservation(Request $request) {
        try {
            $r = DB::table('reservations')->insert(
                ['created_by' => $request['uid'], 'payment_status' => 0, 'created_at' => Carbon::now()]
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
        try {
            if (isset($request['res_id']) && isset($request['ticket_id']) && 
                isset($request['email']) && isset($request['first_name']) && isset($request['last_name'])) {
                
                $ticket = DB::table('tickets')
                ->where('id','=', $request['ticket_id'])->whereNull('reservation')->first();
                if (!$ticket) {
                    abort(404);
                }
                if ($ticket->created_at < Carbon::now()->subMinutes(10)) {
                    $ticket->delete();
                    abort(408);
                }
                DB::table('tickets')
                ->where('id', $request['ticket_id'])
                ->update([
                    'reservation' => $request['res_id'],
                    'email' => $request['email'],
                    'first_name' => $request['first_name'],
                    'last_name' => $request['last_name']]);
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
        try {
            if (isset($request['res_id'])) {
                $reservation = DB::table('reservations')
                    ->where('id', $request['res_id'])->first();

                DB::table('tickets')
                ->where('reservation', '=', $reservation->id)->delete();
            } else {
                abort(400);
            }
        } catch (Exception $e) {
            abort(500);
        }
            
    }
}
