<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Ride;
use App\Models\RideRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class RideRequestController extends Controller
{
    /**
     * Solicitar participação em uma carona
     */
    public function store(Request $request, Ride $ride)
    {
        $user = Auth::user();

        if (!$user->isPassenger()) {
            return response()->json([
                'message' => 'Apenas passageiros podem solicitar caronas.'
            ], 403);
        }

        if ($ride->driver_id === $user->id) {
            return response()->json([
                'message' => 'Você não pode solicitar sua própria carona.'
            ], 422);
        }

        if (!$ride->hasAvailableSeats()) {
            return response()->json([
                'message' => 'Esta carona não possui vagas disponíveis.'
            ], 422);
        }

        // Verifica se já existe uma solicitação
        $existingRequest = RideRequest::where('ride_id', $ride->id)
                                    ->where('passenger_id', $user->id)
                                    ->first();

        if ($existingRequest) {
            return response()->json([
                'message' => 'Você já solicitou esta carona.'
            ], 422);
        }

        $request->validate([
            'message' => 'nullable|string|max:500'
        ]);

        $rideRequest = RideRequest::create([
            'ride_id' => $ride->id,
            'passenger_id' => $user->id,
            'message' => $request->message,
        ]);

        $rideRequest->load(['passenger', 'ride.driver']);

        return response()->json([
            'message' => 'Solicitação enviada com sucesso!',
            'request' => $rideRequest
        ], 201);
    }

    /**
     * Aceitar uma solicitação de carona
     */
    public function accept(RideRequest $rideRequest)
    {
        $user = Auth::user();

        if ($rideRequest->ride->driver_id !== $user->id) {
            return response()->json([
                'message' => 'Você não tem permissão para aceitar esta solicitação.'
            ], 403);
        }

        if ($rideRequest->status !== 'pending') {
            return response()->json([
                'message' => 'Esta solicitação já foi processada.'
            ], 422);
        }

        if (!$rideRequest->ride->hasAvailableSeats()) {
            return response()->json([
                'message' => 'Não há mais vagas disponíveis nesta carona.'
            ], 422);
        }

        $rideRequest->update(['status' => 'accepted']);
        $rideRequest->load(['passenger', 'ride']);

        return response()->json([
            'message' => 'Solicitação aceita com sucesso!',
            'request' => $rideRequest
        ]);
    }

    /**
     * Rejeitar uma solicitação de carona
     */
    public function reject(RideRequest $rideRequest)
    {
        $user = Auth::user();

        if ($rideRequest->ride->driver_id !== $user->id) {
            return response()->json([
                'message' => 'Você não tem permissão para rejeitar esta solicitação.'
            ], 403);
        }

        if ($rideRequest->status !== 'pending') {
            return response()->json([
                'message' => 'Esta solicitação já foi processada.'
            ], 422);
        }

        $rideRequest->update(['status' => 'rejected']);
        $rideRequest->load(['passenger', 'ride']);

        return response()->json([
            'message' => 'Solicitação rejeitada.',
            'request' => $rideRequest
        ]);
    }

    /**
     * Lista as solicitações de uma carona específica (para o motorista)
     */
    public function rideRequests(Ride $ride)
    {
        $user = Auth::user();

        if ($ride->driver_id !== $user->id) {
            return response()->json([
                'message' => 'Você não tem permissão para ver estas solicitações.'
            ], 403);
        }

        $requests = $ride->requests()
                        ->with('passenger')
                        ->orderBy('created_at', 'desc')
                        ->get();

        return response()->json($requests);
    }

    /**
     * Lista as solicitações do usuário autenticado (para passageiros)
     */
    public function myRequests()
    {
        $user = Auth::user();

        if (!$user->isPassenger()) {
            return response()->json([
                'message' => 'Apenas passageiros podem ver suas solicitações.'
            ], 403);
        }

        $requests = $user->rideRequests()
                        ->with(['ride.driver', 'ride.vehiclePhotos'])
                        ->orderBy('created_at', 'desc')
                        ->get();

        return response()->json($requests);
    }

    /**
     * Cancelar uma solicitação de carona
     */
    public function cancel(RideRequest $rideRequest)
    {
        $user = Auth::user();

        if ($rideRequest->passenger_id !== $user->id) {
            return response()->json([
                'message' => 'Você não tem permissão para cancelar esta solicitação.'
            ], 403);
        }

        if ($rideRequest->status === 'accepted') {
            return response()->json([
                'message' => 'Não é possível cancelar uma solicitação já aceita.'
            ], 422);
        }

        $rideRequest->delete();

        return response()->json([
            'message' => 'Solicitação cancelada com sucesso!'
        ]);
    }
}
