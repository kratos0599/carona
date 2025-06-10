import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isDriver => _user?['role'] == 'driver';
  bool get isPassenger => _user?['role'] == 'passenger';

  Future<void> loadUser() async {
    _setLoading(true);
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token != null) {
      final response = await ApiService.getUser();
      if (response['success']) {
        _user = response['data']['user'];
        _clearError();
      } else {
        await logout();
      }
    }
    
    _setLoading(false);
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    final response = await ApiService.login(email, password);
    
    if (response['success']) {
      final data = response['data'];
      _user = data['user'];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token']);
      
      _setLoading(false);
      return true;
    } else {
      _setError(response['message']);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _setLoading(true);
    _clearError();
    
    final response = await ApiService.register(userData);
    
    if (response['success']) {
      final data = response['data'];
      _user = data['user'];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token']);
      
      _setLoading(false);
      return true;
    } else {
      _setError(response['message']);
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
} 