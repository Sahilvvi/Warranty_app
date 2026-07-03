import 'package:flutter/material.dart';
import '../models/consumer_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class ConsumerProvider with ChangeNotifier {
  List<ConsumerModel> _consumers = [];
  bool _isLoading = false;
  String? _error;

  List<ConsumerModel> get consumers => _consumers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchConsumers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get(ApiConfig.consumers);
      if (response['success'] == true) {
        _consumers = (response['data'] as List)
            .map((e) => ConsumerModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createConsumer({
    required String name,
    String? address,
    required String mobileNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post(ApiConfig.consumers, {
        'name': name,
        'address': address,
        'mobileNumber': mobileNumber,
      });

      _isLoading = false;
      if (response['success'] == true) {
        await fetchConsumers();
        return true;
      } else {
        _error = response['message'];
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

  Future<bool> updateConsumer({
    required int id,
    required String name,
    String? address,
    required String mobileNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.put(ApiConfig.consumerById(id), {
        'name': name,
        'address': address,
        'mobileNumber': mobileNumber,
      });

      _isLoading = false;
      if (response['success'] == true) {
        await fetchConsumers();
        return true;
      } else {
        _error = response['message'];
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

  Future<void> searchByMobile(String mobile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get(ApiConfig.consumerSearch(mobile));
      if (response['success'] == true) {
        _consumers = (response['data'] as List)
            .map((e) => ConsumerModel.fromJson(e))
            .toList();
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
