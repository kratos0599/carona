<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable, HasApiTokens;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'phone',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * Caronas oferecidas pelo usuário (para motoristas)
     */
    public function ridesOffered()
    {
        return $this->hasMany(Ride::class, 'driver_id');
    }

    /**
     * Solicitações de carona feitas pelo usuário (para passageiros)
     */
    public function rideRequests()
    {
        return $this->hasMany(RideRequest::class, 'passenger_id');
    }

    /**
     * Verifica se o usuário é motorista
     */
    public function isDriver()
    {
        return $this->role === 'driver';
    }

    /**
     * Verifica se o usuário é passageiro
     */
    public function isPassenger()
    {
        return $this->role === 'passenger';
    }
}
