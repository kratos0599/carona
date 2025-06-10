import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8001/api';
  
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Autenticação
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: await _getHeaders(),
        body: jsonEncode(userData),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: await _getHeaders(),
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  static Future<Map<String, dynamic>> getUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: await _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  // Caronas
  static Future<Map<String, dynamic>> getRides({Map<String, String>? filters}) async {
    try {
      String url = '$baseUrl/rides';
      if (filters != null && filters.isNotEmpty) {
        final queryString = filters.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url += '?$queryString';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  static Future<Map<String, dynamic>> getRide(int rideId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rides/$rideId'),
        headers: await _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  static Future<Map<String, dynamic>> createRide(Map<String, dynamic> rideData, {List<File>? photos, List<XFile>? photoFiles}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/rides'));
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';
      
      // Adicionar campos de dados
      rideData.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      
      // Adicionar fotos se existirem
      if (kIsWeb && photoFiles != null && photoFiles.isNotEmpty) {
        // Para Web: usar XFile
        for (int i = 0; i < photoFiles.length; i++) {
          final xFile = photoFiles[i];
          final bytes = await xFile.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'photos[]',
              bytes,
              filename: xFile.name,
            ),
          );
        }
      } else if (!kIsWeb && photos != null && photos.isNotEmpty) {
        // Para Mobile: usar File
        for (int i = 0; i < photos.length; i++) {
          final file = photos[i];
          request.files.add(
            await http.MultipartFile.fromPath(
              'photos[]',
              file.path,
            ),
          );
        }
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  static Future<Map<String, dynamic>> requestRide(int rideId, {String? message}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rides/$rideId/request'),
        headers: await _getHeaders(),
        body: jsonEncode({'message': message}),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  static Future<Map<String, dynamic>> getMyRides() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my-rides'),
        headers: await _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteRide(int rideId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/rides/$rideId'),
        headers: await _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  static Future<Map<String, dynamic>> getRideRequests(int rideId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rides/$rideId/requests'),
        headers: await _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  static Future<Map<String, dynamic>> respondToRideRequest(int requestId, String action) async {
    try {
      final endpoint = action == 'accept' 
          ? '$baseUrl/ride-requests/$requestId/accept'
          : '$baseUrl/ride-requests/$requestId/reject';
          
      final response = await http.put(
        Uri.parse(endpoint),
        headers: await _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  // Novos métodos para solicitações de passageiros
  static Future<Map<String, dynamic>> getMyRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my-requests'),
        headers: await _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  static Future<Map<String, dynamic>> cancelRideRequest(int requestId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/ride-requests/$requestId'),
        headers: await _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro desconhecido'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao processar resposta: $e'
      };
    }
  }
} 