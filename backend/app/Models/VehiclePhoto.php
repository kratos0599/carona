<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Support\Facades\Storage;

class VehiclePhoto extends Model
{
    use HasFactory;

    protected $fillable = [
        'ride_id',
        'photo_path',
        'original_name',
        'file_size',
        'mime_type',
        'order',
    ];

    /**
     * Carona associada à foto
     */
    public function ride()
    {
        return $this->belongsTo(Ride::class);
    }

    /**
     * Retorna a URL completa da foto
     */
    public function getUrlAttribute()
    {
        return Storage::url($this->photo_path);
    }

    /**
     * Retorna o tamanho do arquivo formatado
     */
    public function getFormattedSizeAttribute()
    {
        $size = $this->file_size;
        if ($size >= 1024 * 1024) {
            return round($size / (1024 * 1024), 2) . ' MB';
        } elseif ($size >= 1024) {
            return round($size / 1024, 2) . ' KB';
        }
        return $size . ' bytes';
    }
}
