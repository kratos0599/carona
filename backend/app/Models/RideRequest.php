<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class RideRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'ride_id',
        'passenger_id',
        'status',
        'message',
    ];

    /**
     * Carona solicitada
     */
    public function ride()
    {
        return $this->belongsTo(Ride::class);
    }

    /**
     * Passageiro que fez a solicitação
     */
    public function passenger()
    {
        return $this->belongsTo(User::class, 'passenger_id');
    }

    /**
     * Scope para solicitações pendentes
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    /**
     * Scope para solicitações aceitas
     */
    public function scopeAccepted($query)
    {
        return $query->where('status', 'accepted');
    }
}
