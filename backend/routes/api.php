<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\RideController;
use App\Http\Controllers\Api\RideRequestController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Rotas públicas (sem autenticação)
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Listar caronas disponíveis (público para pesquisa)
Route::get('/rides', [RideController::class, 'index']);
Route::get('/rides/{ride}', [RideController::class, 'show']);

// Rotas protegidas (com autenticação)
Route::middleware('auth:sanctum')->group(function () {
    // Autenticação
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    
    // Caronas - CRUD
    Route::post('/rides', [RideController::class, 'store']);
    Route::put('/rides/{ride}', [RideController::class, 'update']);
    Route::delete('/rides/{ride}', [RideController::class, 'destroy']);
    Route::get('/my-rides', [RideController::class, 'myRides']);
    
    // Solicitações de carona
    Route::post('/rides/{ride}/request', [RideRequestController::class, 'store']);
    Route::get('/rides/{ride}/requests', [RideRequestController::class, 'rideRequests']);
    Route::get('/my-requests', [RideRequestController::class, 'myRequests']);
    
    // Gerenciar solicitações (aceitar/rejeitar)
    Route::put('/ride-requests/{rideRequest}/accept', [RideRequestController::class, 'accept']);
    Route::put('/ride-requests/{rideRequest}/reject', [RideRequestController::class, 'reject']);
    Route::delete('/ride-requests/{rideRequest}', [RideRequestController::class, 'cancel']);
}); 