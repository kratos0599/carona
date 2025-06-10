<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreRideRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'origin' => 'required|string|max:255',
            'destination' => 'required|string|max:255',
            'departure_time' => 'required|date|after:now',
            'available_seats' => 'required|integer|min:1|max:8',
            'price' => 'required|numeric|min:0',
            'description' => 'nullable|string|max:1000',
            'vehicle_model' => 'required|string|max:255',
            'vehicle_color' => 'nullable|string|max:50',
            'vehicle_plate' => 'nullable|string|max:10',
            'vehicle_photos' => 'nullable|array|max:5',
            'vehicle_photos.*' => 'image|mimes:jpeg,png,jpg,gif|max:2048',
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'origin.required' => 'O local de origem é obrigatório.',
            'destination.required' => 'O destino é obrigatório.',
            'departure_time.required' => 'O horário de saída é obrigatório.',
            'departure_time.after' => 'O horário de saída deve ser no futuro.',
            'available_seats.required' => 'O número de vagas é obrigatório.',
            'available_seats.min' => 'Deve haver pelo menos 1 vaga disponível.',
            'available_seats.max' => 'O número máximo de vagas é 8.',
            'price.required' => 'O preço é obrigatório.',
            'price.min' => 'O preço não pode ser negativo.',
            'vehicle_model.required' => 'O modelo do veículo é obrigatório.',
            'vehicle_photos.max' => 'Você pode enviar no máximo 5 fotos do veículo.',
            'vehicle_photos.*.image' => 'Cada arquivo deve ser uma imagem.',
            'vehicle_photos.*.mimes' => 'As imagens devem ser dos tipos: jpeg, png, jpg, gif.',
            'vehicle_photos.*.max' => 'Cada imagem deve ter no máximo 2MB.',
        ];
    }
}
