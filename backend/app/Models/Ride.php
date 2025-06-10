<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Ride extends Model
{
    use HasFactory;

    protected $fillable = [
        'driver_id',
        'origin',
        'destination',
        'departure_time',
        'available_seats',
        'price',
        'description',
        'vehicle_model',
        'vehicle_color',
        'vehicle_plate',
        'status',
    ];

    protected $casts = [
        'departure_time' => 'datetime',
        'price' => 'decimal:2',
    ];

    /**
     * Motorista que oferece a carona
     */
    public function driver()
    {
        return $this->belongsTo(User::class, 'driver_id');
    }

    /**
     * Solicitações para esta carona
     */
    public function requests()
    {
        return $this->hasMany(RideRequest::class);
    }

    /**
     * Fotos do veículo
     */
    public function vehiclePhotos()
    {
        return $this->hasMany(VehiclePhoto::class)->orderBy('order');
    }

    /**
     * Passageiros aceitos nesta carona
     */
    public function acceptedPassengers()
    {
        return $this->belongsToMany(User::class, 'ride_requests', 'ride_id', 'passenger_id')
                    ->wherePivot('status', 'accepted');
    }

    /**
     * Verifica se ainda há vagas disponíveis
     */
    public function hasAvailableSeats()
    {
        $acceptedRequests = $this->requests()->where('status', 'accepted')->count();
        return $this->available_seats > $acceptedRequests;
    }

    /**
     * Scope para caronas ativas
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active')
                    ->where('departure_time', '>', now());
    }
}
