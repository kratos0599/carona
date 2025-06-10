<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreRideRequest;
use App\Models\Ride;
use App\Models\VehiclePhoto;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\Laravel\Facades\Image;

class RideController extends Controller
{
    /**
     * Lista todas as caronas disponíveis com filtros
     */
    public function index(Request $request)
    {
        $query = Ride::with(['driver', 'vehiclePhotos'])
                    ->active()
                    ->where('driver_id', '!=', Auth::id());

        // Filtros
        if ($request->filled('origin')) {
            $query->where('origin', 'like', '%' . $request->origin . '%');
        }

        if ($request->filled('destination')) {
            $query->where('destination', 'like', '%' . $request->destination . '%');
        }

        if ($request->filled('date')) {
            $query->whereDate('departure_time', $request->date);
        }

        if ($request->filled('max_price')) {
            $query->where('price', '<=', $request->max_price);
        }

        $rides = $query->orderBy('departure_time', 'asc')->paginate(10);

        return response()->json($rides);
    }

    /**
     * Cria uma nova carona
     */
    public function store(StoreRideRequest $request)
    {
        if (!Auth::user()->isDriver()) {
            return response()->json([
                'message' => 'Apenas motoristas podem criar caronas.'
            ], 403);
        }

        $ride = Ride::create([
            'driver_id' => Auth::id(),
            'origin' => $request->origin,
            'destination' => $request->destination,
            'departure_time' => $request->departure_time,
            'available_seats' => $request->available_seats,
            'price' => $request->price,
            'description' => $request->description,
            'vehicle_model' => $request->vehicle_model,
            'vehicle_color' => $request->vehicle_color,
            'vehicle_plate' => $request->vehicle_plate,
        ]);

        // Upload das fotos do veículo
        if ($request->hasFile('vehicle_photos')) {
            $this->uploadVehiclePhotos($ride, $request->file('vehicle_photos'));
        }

        $ride->load(['driver', 'vehiclePhotos']);

        return response()->json([
            'message' => 'Carona criada com sucesso!',
            'ride' => $ride
        ], 201);
    }

    /**
     * Exibe uma carona específica
     */
    public function show(Ride $ride)
    {
        $ride->load(['driver', 'vehiclePhotos', 'requests.passenger']);
        
        return response()->json($ride);
    }

    /**
     * Atualiza uma carona
     */
    public function update(StoreRideRequest $request, Ride $ride)
    {
        if ($ride->driver_id !== Auth::id()) {
            return response()->json([
                'message' => 'Você não tem permissão para editar esta carona.'
            ], 403);
        }

        $ride->update([
            'origin' => $request->origin,
            'destination' => $request->destination,
            'departure_time' => $request->departure_time,
            'available_seats' => $request->available_seats,
            'price' => $request->price,
            'description' => $request->description,
            'vehicle_model' => $request->vehicle_model,
            'vehicle_color' => $request->vehicle_color,
            'vehicle_plate' => $request->vehicle_plate,
        ]);

        // Upload de novas fotos, se fornecidas
        if ($request->hasFile('vehicle_photos')) {
            // Remove fotos antigas
            $this->deleteVehiclePhotos($ride);
            // Adiciona novas fotos
            $this->uploadVehiclePhotos($ride, $request->file('vehicle_photos'));
        }

        $ride->load(['driver', 'vehiclePhotos']);

        return response()->json([
            'message' => 'Carona atualizada com sucesso!',
            'ride' => $ride
        ]);
    }

    /**
     * Remove uma carona
     */
    public function destroy(Ride $ride)
    {
        if ($ride->driver_id !== Auth::id()) {
            return response()->json([
                'message' => 'Você não tem permissão para excluir esta carona.'
            ], 403);
        }

        // Remove fotos do veículo
        $this->deleteVehiclePhotos($ride);

        $ride->delete();

        return response()->json([
            'message' => 'Carona excluída com sucesso!'
        ]);
    }

    /**
     * Lista as caronas do usuário autenticado
     */
    public function myRides()
    {
        $user = Auth::user();

        if ($user->isDriver()) {
            $rides = $user->ridesOffered()
                         ->with(['vehiclePhotos', 'requests.passenger'])
                         ->orderBy('departure_time', 'desc')
                         ->get();
            
            // Adicionar contagem de solicitações pendentes para cada carona
            $rides->each(function ($ride) {
                $ride->pending_requests_count = $ride->requests()->where('status', 'pending')->count();
            });
        } else {
            $rides = $user->rideRequests()
                         ->with(['ride.driver', 'ride.vehiclePhotos'])
                         ->orderBy('created_at', 'desc')
                         ->get()
                         ->pluck('ride');
        }

        return response()->json($rides);
    }

    /**
     * Upload das fotos do veículo
     */
    private function uploadVehiclePhotos(Ride $ride, array $photos)
    {
        foreach ($photos as $index => $photo) {
            $filename = time() . '_' . $index . '.' . $photo->getClientOriginalExtension();
            $path = 'vehicle-photos/' . $filename;

            // Redimensiona e otimiza a imagem
            $image = Image::read($photo)
                         ->resize(800, 600, function ($constraint) {
                             $constraint->aspectRatio();
                             $constraint->upsize();
                         });

            Storage::disk('public')->put($path, (string) $image->encode());

            VehiclePhoto::create([
                'ride_id' => $ride->id,
                'photo_path' => $path,
                'original_name' => $photo->getClientOriginalName(),
                'file_size' => $photo->getSize(),
                'mime_type' => $photo->getMimeType(),
                'order' => $index,
            ]);
        }
    }

    /**
     * Remove fotos do veículo
     */
    private function deleteVehiclePhotos(Ride $ride)
    {
        foreach ($ride->vehiclePhotos as $photo) {
            Storage::disk('public')->delete($photo->photo_path);
            $photo->delete();
        }
    }
}
