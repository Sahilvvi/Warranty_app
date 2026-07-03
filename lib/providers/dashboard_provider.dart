import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class DashboardProvider with ChangeNotifier {
  DashboardData? _dashboard;
  bool _isLoading = false;
  String? _error;

  DashboardData? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get(ApiConfig.dashboard);
      if (response['success'] == true) {
        _dashboard = DashboardData.fromJson(response['data']);
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
