import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class AuthProvider with ChangeNotifier {
  LoginResponse? _loginData;
  bool _isLoading = false;
  String? _error;

  LoginResponse? get loginData => _loginData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _loginData != null;
  String get role => _loginData?.role ?? '';
  String get fullName => _loginData?.fullName ?? '';
  String get username => _loginData?.username ?? '';

  AuthProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final username = prefs.getString('username');
    final fullName = prefs.getString('fullName');
    final role = prefs.getString('role');
    final expiresAt = prefs.getString('expiresAt');

    if (token != null && expiresAt != null) {
      final expiry = DateTime.parse(expiresAt);
      if (expiry.isAfter(DateTime.now())) {
        _loginData = LoginResponse(
          token: token,
          username: username ?? '',
          fullName: fullName ?? '',
          role: role ?? '',
          expiresAt: expiry,
        );
        notifyListeners();
      } else {
        await _clearSession();
      }
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post(ApiConfig.login, {
        'username': username,
        'password': password,
      });

      if (response['success'] == true) {
        final data = response['data'];
        _loginData = LoginResponse.fromJson(data);
        await _saveSession();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveSession() async {
    if (_loginData == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _loginData!.token);
    await prefs.setString('username', _loginData!.username);
    await prefs.setString('fullName', _loginData!.fullName);
    await prefs.setString('role', _loginData!.role);
    await prefs.setString('expiresAt', _loginData!.expiresAt.toIso8601String());
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
    await prefs.remove('fullName');
    await prefs.remove('role');
    await prefs.remove('expiresAt');
  }

  Future<void> logout() async {
    _loginData = null;
    await _clearSession();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
